class Timer < ActiveRecord::Base
  States = %w(active paused completed)
  
  include Ticktock::Subjects
  
  belongs_to :account
  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  
  before_save :handle_state_change
  
  include AASM
  aasm_initial_state :active
  aasm_state         :active
  aasm_state         :paused
  aasm_state         :completed
  
  def state
    States[(self.status ||= 0)]
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

  def handle_state_change
    if new_record?
      self.start ||= Time.zone.now and return
    end
    
    return unless self.status_changed?
    return if new_record?
    
    @last_state_change_at = (self.state_changed_at || self.start)
    self.state_changed_at = Time.zone.now
    
    old_state, new_state = self.state_change
    logger.debug("State has changed from #{old_state} to #{new_state}")
    
    if self.state_was == 0
      punch_duration = (@last_state_change_at - self.state_changed_at).abs
    else
      punch_duration = 0
    end
    
    # self.duration ||= 0
    # if self.punches.count > 0
    #   self.duration += punch_duration
    # else
    #   self.duration  = punch_duration
    # end
    
    self.punches.build({
      :from_state => old_state,
      :to_state   => new_state,
      :duration   => punch_duration,
      :start      => @last_state_change_at,
      :stop       => self.state_changed_at
    })
    
    @last_state_change_at = nil
  end
  
end
