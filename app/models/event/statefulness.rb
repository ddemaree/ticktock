module Event::Statefulness
  
  def self.included(base)
    base.class_eval do
      include AASM
      
      alias_attribute    :aasm_state, :state
      aasm_initial_state :active
      aasm_state         :active
      aasm_state         :sleeping
      aasm_state         :completed
      
      before_validation  :update_state
      before_save        :handle_state_change
      
      attr_accessor :previous_state_change_at
    end
  end

  def finish
    self.state = 'completed'
    self.stop  = Time.now
  end

  def finish!
    self.finish and save!
  end
  
  def sleep
    self.state = 'sleeping'
  end
  
  def sleep!
    self.sleep && self.save!
  end
  
  def wake
    self.state   = 'active'
    self.start ||= Time.now
  end

  def wake!
    self.wake && self.save!
  end
  
  def last_state_change_at
    @last_state_change_at ||= (self.state_changed_at || self.start)
  end

protected

  def handle_state_change
    return unless self.state_changed?
    return if new_record?
    
    @last_state_change_at = (self.state_changed_at || self.start)
    self.state_changed_at = Time.now
    
    old_state, new_state = self.state_change
    logger.debug("State has changed from #{old_state} to #{new_state}")
    
    if self.state_was == "active"
      punch_duration = (@last_state_change_at - self.state_changed_at).abs
    else
      punch_duration = 0
    end
    
    self.duration ||= 0
    if self.punches.count > 0
      self.duration += punch_duration
    else
      self.duration  = punch_duration
    end
    
    self.punches.build({
      :from_state => old_state,
      :to_state   => new_state,
      :duration   => punch_duration,
      :start      => @last_state_change_at,
      :stop       => self.state_changed_at
    })
    
    @last_state_change_at = nil
  end

  def update_state
    self.state = 
      if state == "sleeping"
        "sleeping"
      elsif stop.blank? and !start.blank?
        "active"
      else #elsif start.blank? and stop.blank?
        "completed"
      end
      
    self.state_changed_at ||= self.last_state_change_at
  end
  
end