require 'digest/sha1'

class Event < ActiveRecord::Base
  cattr_accessor :options
  @@options = {
    :hours_to_nearest => 0.25
  }
  
  include Event::Statefulness
  include Event::Taggable
  include Event::Importing
  
  # #   S C O P E S   # #
  default_scope :order => "date DESC, start DESC, created_at DESC"
  named_scope   :active, :conditions => { :state => 'active' }
  
  named_scope :for_date_range, lambda { |range|
    raise ArgumentError, "Argument passed to Event.for_date_range must be range" unless range.is_a?(Range)
    {:conditions => {:date => range}}
  }
  
  # #   A S S O C I A T I O N S   # #
  belongs_to :account
  belongs_to :subject, :polymorphic => true
  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  has_many   :punches, :dependent => :destroy
  
  # #   C A L L B A C K S   # #
  before_validation_on_create :set_date_from_start_if_blank
  before_validation           :set_duration_if_available
  before_validation           :set_kind_if_blank
  before_validation           :set_user_name_if_blank
  
  # #   V A L I D A T I O N S   # #
  validates_presence_of   :body, :account#, :user
  validate                :stop_must_be_after_start
  validate                :start_or_date_present
  
  
  def class_options
    self.class.options
  end
  
  def duration_in_hours(options={})
    return nil if duration.nil?
    
    options.reverse_merge!({
      :precision => 2,
      :raw => nil,
      :nearest => (class_options[:hours_to_nearest])
    })
    
    hours = (duration.to_f / 3600.0)
    return hours if options[:raw]
    
    if nearest = options[:nearest]
      base_hours = (hours - (hours % nearest))
      base_hours += nearest if ((hours % nearest) > (nearest / 2))
      return base_hours
    end
    
    precision = options[:precision]
    (Float(hours) * (10 ** precision)).round.to_f / 10 ** precision
  end
  alias_method :hours, :duration_in_hours
  
  def duration_in_hours=(hours)
    self.duration = hours.to_f.hours.to_i
  end
  alias_method :hours=, :duration_in_hours=
  
  def duration
    if active? && !read_attribute(:duration)
      Time.now - self.start
    else
      read_attribute(:duration)
    end
  end
  
  def duration=(int_or_string)
    case int_or_string
    when String
      write_attribute(:duration, Event::TimeParser.from_string(int_or_string))
    else
      write_attribute(:duration, int_or_string)
    end
  end
  
  def body=(message)
    params = MessageParser.parse(:body => message)
    logger.debug("\n\n#{params.inspect}\n\n")
    
    self.tags = params[:tags]
    self.subject = params[:subject]
    write_attribute :body, params[:body]
    
    params[:body]
  end
  
  
  def user=(user_or_username)
    case user_or_username
      when User
        write_attribute :user_id, user_or_username.id
        self.user_name = (user_or_username.name || user_or_username.login)
      when String
        return nil if account.nil?
        unless self.user = account.users.find_by_login(user_or_username)
          self.user_name = user_or_username
        end
    end
  end
  
  alias_method :subject_from_object=, :subject=
  def subject=(object_or_name)
    if object_or_name.is_a?(String)
      if obj = self.account.trackables.find_by_name(object_or_name) ||
               self.account.trackables.find_by_nickname(object_or_name)
        
        self.subject_from_object = obj
      else
        self.subject_from_object = self.account.trackables.build(:nickname => object_or_name)
      end
    else
      self.subject_from_object = object_or_name
    end
  end
  
protected

  def set_date_from_start_if_blank
    self.date ||= self.start.try(:to_date) || Date.today
  end
  
  def set_duration_if_available
    if self.punches.count > 0
      logger.debug("Setting event duration from punches")
      self.duration = self.punches.sum(:duration)
    else
      return if (start.blank? or stop.blank?)
      self.duration = (start - stop).abs.to_i
    end
  end
  
  def set_kind_if_blank
    self.kind ||= "event"
  end
  
  def set_user_name_if_blank
    self.user_name ||= self.user.try(:name)
  end

  def start_or_date_present
    if start.blank? && date.blank?
      errors.add_to_base("Date or start time must be provided")
    end
  end

  def stop_must_be_after_start
    return true if stop.blank?
    
    if start >= stop
      errors.add(:stop, "cannot be earlier than the start time")
    end
  end
  
end
