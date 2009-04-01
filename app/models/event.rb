require 'digest/sha1'

class Event < ActiveRecord::Base
  cattr_accessor :options
  @@options = {
    :hours_to_nearest => 0.25
  }
  
  serialize_with({
    :include => {:user => User.serialization_defaults, :subject => Trackable.serialization_defaults},
    :methods => [:tags, :errors, :quick_body],
    :only    => [:id, :body, :date, :start, :stop, :duration, :subject_id]
  })
  
  #include Event::Statefulness
  include Event::Taggable
  include Event::Importing
  include Event::Filtering
  
  include Ticktock::Reportable
  include Ticktock::Subjects
  
  # #   S C O P E S   # #
  default_scope :order => "events.date DESC, events.start DESC, events.created_at DESC"
  
  named_scope :active_projects, :joins => "LEFT OUTER JOIN trackables ON trackables.id = events.subject_id", :conditions => "trackables.id IS NULL OR trackables.state = 'active'"
  
  named_scope :active, :conditions => { :state => 'active' }
  named_scope :recent, lambda {|num| {:limit => (num||20), :conditions => {:date_gte => 2.weeks.ago}} }
  
  named_scope :for_date_range, lambda { |range|
    raise ArgumentError, "Argument passed to Event.for_date_range must be range" unless range.is_a?(Range)
    {:conditions => {:date => range}}
  }
  
  # #   A S S O C I A T I O N S   # #
  belongs_to :account
  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  has_one    :timer, :dependent => :destroy
  
  # #   C A L L B A C K S   # #
  before_validation_on_create :set_date_from_start_if_blank
  before_validation           :set_duration_if_available
  before_validation           :set_kind_if_blank
  before_validation           :set_user_name_if_blank
  
  # #   V A L I D A T I O N S   # #
  validates_presence_of   :body, :account#, :user
  validate                :stop_must_be_after_start
  validate                :start_or_date_present
  
  attr_accessor :source
  
  class << self
  
    def find_and_extend(*args,&block)
      options = (args.pop || {})
      finder = (options[:finder] || 'find').to_s
      
      if finder == 'find'
        # an array of IDs may have been given:
        total_entries ||= (Array === args.first and args.first.size)
        # :all is implicit
        args.unshift(:all) if args.empty?
      end
      
      args << options
      
      EventSet.new(send(finder, *args, &block))      
    end
  
  end
  
  def class_options
    self.class.options
  end
  
  def permalink
    "/calendar/#{date.year}/w/#{date.cweek}#event_#{id}"
  end
  
  def duration_as_string
    Ticktock::Durations.duration_to_string(duration)
  end
  
  def duration_as_string=(time)
    self.duration = time
  end
  
  def duration=(int_or_string)
    return @duration_set_via_body if @duration_set_via_body
    
    case int_or_string
    when String
      write_attribute(:duration, Event::TimeParser.from_string(int_or_string))
    else
      write_attribute(:duration, int_or_string)
    end
  end
  
  def date=(date_or_string)
    return @date_set_via_body if @date_set_via_body
    write_attribute(:date, date_or_string)
  end
  
  attr_reader :parsed_params
  def body=(message)
    return nil if message.nil?
    
    @parsed_params = MessageParser.parse(:body => message)
    logger.debug("\n\n#{@parsed_params.inspect}\n\n")
    
    self.tags = @parsed_params[:tags] #if self.tags.empty?
    
    # Subject has been changed this session; if this has happened prior to
    # this setter being called, that means the user has set the subject
    # separately from the body so that setting should be honored.
    # Using an ivar because this may have happened for a new record, therefore
    # self.subject_id_changed? would not return true
    unless @subject_changed
      if self.subject && (!@parsed_params[:subject] || @parsed_params[:subject].blank?)
        logger.debug("Nullifying #{self.subject.inspect}")
        self.subject = nil
      else
        self.subject = @parsed_params[:subject]
      end
    end
    
    if @parsed_params[:duration]
      self.duration  = @parsed_params[:duration]
      @duration_set_via_body = @parsed_params[:duration]
    end
    
    if @parsed_params[:date] && !@parsed_params[:date].blank?
      self.date = @parsed_params[:date]
      @date_set_via_body = @parsed_params[:date]
    end
    
      #self.duration.blank?
    write_attribute :body, @parsed_params[:body]
    
    @parsed_params[:body]
  end
  
  def quick_body
    returning("") do |output|
      output << "@#{subject.nickname} " if subject
      
      date_string = date.strftime("%m/%d/%Y")
      output << "#{date_string} "
      
      if duration.to_i > 0
        duration_string = Ticktock::Durations.duration_to_string(duration, "%H:%N")
        output << "#{duration_string} "
      end
      
      output << body
    end
  end
  
  def quick_body=(message)
    self.body = message
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
  

  
protected

  def set_date_from_start_if_blank
    self.date ||= (self.start.try(:to_date) || Time.zone.now.to_date || Date.today)
  end
  
  def set_duration_if_available
    return if (start.blank? or stop.blank?)
    self.duration = (start - stop).abs.to_i
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
