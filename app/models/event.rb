class Event < ActiveRecord::Base
  
  # #   S C O P E S   # #
  named_scope :active, :conditions => { :state => 'active' }
  
  # #   S T A T E S   # #
  include AASM
  alias_attribute :aasm_state, :state
  aasm_initial_state :active
  aasm_state :active
  aasm_state :sleeping
  aasm_state :completed
  
  aasm_event :wake do
    transitions :to => :active, :from => [:sleeping, :completed, :active],
                :on_transition => Proc.new { |e| e.start ||= Time.now }
  end
  
  aasm_event :sleep do
    transitions :to => :sleeping, :from => [:active, :sleeping]
  end
  
  aasm_event :finish do
    transitions :to => :completed, :from => [:active, :sleeping], 
                :on_transition => Proc.new { |e| e.stop = Time.now }
  end
  
  # #   A S S O C I A T I O N S   # #
  belongs_to :account
  belongs_to :subject, :polymorphic => true
  belongs_to :user
  
  # #   C A L L B A C K S   # #
  before_validation_on_create :set_date_from_start_if_blank
  before_validation :update_state
  before_validation :set_duration_if_available
  before_validation :set_kind_if_blank
  before_validation :set_user_name_if_blank
  
  # #   V A L I D A T I O N S   # #
  validates_presence_of :body, :account#, :user
  validate :stop_must_be_after_start
  validate :start_or_date_present
  
  
  def duration_in_hours
    (duration / 3600.0)
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
    self.date ||= self.start.try(:to_date)
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

  def update_state
    self.state = 
      if stop.blank? and !start.blank?
        "active"
      else #elsif start.blank? and stop.blank?
        "completed"
      end
  end
  
end
