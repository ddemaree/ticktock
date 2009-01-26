class Event < ActiveRecord::Base
  
  class AlreadyHasActive < Exception; end
  
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
  
  # #   V A L I D A T I O N S   # #
  validates_presence_of :body, :account#, :user
  validate :stop_must_be_after_start
  validate :start_or_date_present
  
  
  def duration_in_hours
    (duration / 3600.0)
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
