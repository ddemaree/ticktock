class Timer < ActiveRecord::Base
  States = %w(active paused completed)
  
  include Ticktock::Subjects
  
  belongs_to :account
  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  
  before_validation_on_create :set_start_time
  before_save :handle_state_change
  
  include AASM
  aasm_initial_state :active
  aasm_state         :active
  aasm_state         :paused
  aasm_state         :completed
  
  def state
    States[(status ||= 0)]
  end
  
  def state=(text_or_num)
    self.status = 
      case text_or_num
        when String then States.index(text_or_num)
        when Symbol then States.index(text_or_num.to_s)
        else text_or_num
      end
  end
  
  alias_method :aasm_state, :state
  alias_method :aasm_state=, :state=
  
protected

  def set_start_time
    self.start ||= Time.zone.now
  end

  def handle_state_change
    return unless self.state_changed?
    return if new_record?
    
    @last_state_change_at = (self.state_changed_at || self.start)
    self.state_changed_at = Time.zone.now
  end
  
end
