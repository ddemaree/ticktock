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
    sleep && save!
  end
  
  def wake
    self.state   = 'active'
    self.start ||= Time.now
  end

  def wake!
    wake && save!
  end
  
  
  def last_state_change_at
    @last_state_change_at ||= (state_changed_at || stop || start)
  end


protected

  def handle_state_change
    return unless self.state_changed?
    
    @last_state_change_at = (self.state_changed_at || self.stop || self.start)
    self.state_changed_at = Time.now
    
    old_state, new_state = self.state_change
    logger.debug("State has changed from #{old_state} to #{new_state}")
    
    punch_duration = (self.start - Time.now).abs
      # case new_state
      #   when "sleeping"  then 
      #   when "completed" then self.duration
      # end
    
    self.punches.build({
      :from_state => old_state,
      :to_state   => new_state,
      :duration   => punch_duration
    })
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