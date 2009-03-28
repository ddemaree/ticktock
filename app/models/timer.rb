class Timer < ActiveRecord::Base
  States = %w(active paused completed)

  serialize_with({
    :include => {:user => User.serialization_defaults},
    :methods => [:elapsed, :state, :last_state_change_at],
    :only    => [:id, :body, :status, :start, :stop]
  })
  
  # #   S C O P E S   # #
  default_scope :order => "status ASC"
  named_scope   :open, :conditions => "status < 2"
  
  States.each_with_index do |state, x|
    named_scope state.to_sym, :conditions => "status = #{x}"
  end
  
  # #  A S S O C I A T I O N S  # #
  include Ticktock::Subjects
  belongs_to :event
  belongs_to :account
  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  has_many   :punches, :dependent => :destroy
  
  # #   C A L L B A C K S   # #
  before_save :handle_state_change
  
  # #   S T A T E S   # #
  include AASM
  aasm_initial_state :active
  aasm_state         :active
  aasm_state         :paused
  aasm_state         :completed
  
  def self.current
    active.first
  end
  
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
  
  def finish
    self.state = 'completed'
    self.stop  = Time.now
  end

  def finish!
    self.class.transaction do
      self.finish
      self.create_event!
      save!
    end
  end
  
  def sleep
    self.state = 'paused'
  end
  
  def sleep!
    self.sleep && self.save!
  end
  
  def wake
    self.state   = 'active'
    self.start ||= Time.now
  end

  def wake!
    self.class.transaction do
      self.wake
      self.class.active.each do |timer|
        timer.sleep!
      end
      
      self.save!
    end
  end
  
  alias_method :aasm_state, :state
  alias_method :aasm_state=, :state=
  
  def duration
    self.punches.sum(:duration).to_i
  end
  
  def elapsed
    if self.active?
      (duration + (self.last_state_change_at - Time.now).abs).to_i
    else
      duration.to_i
    end
  end
  
  def last_state_change_at
    @last_state_change_at ||= (self.state_changed_at || self.start)
  end
  
  # cattr_accessor :serialization_defaults
  #   @@serialization_defaults = {
  #     :include => {:user => User.serialization_defaults},
  #     :methods => [:elapsed, :state, :last_state_change_at],
  #     :only    => [:id, :body, :status, :start, :stop]
  #   }
  #   
  #   def serialization_defaults
  #     self.class.serialization_defaults
  #   end
  #   
  #   def to_json(options={})
  #     options.reverse_merge!(serialization_defaults)
  #     super(options)
  #   end
  #   
  #   def to_xml(options={})
  #     options.reverse_merge!(serialization_defaults)
  #     super(options)
  #   end
  
protected

  def handle_state_change
    if new_record?
      self.start ||= Time.zone.now and return
    end
    
    return unless self.status_changed?
    return if new_record?
    
    @last_state_change_at = (self.state_changed_at || self.start)
    self.state_changed_at = Time.zone.now
    
    old_state, new_state = self.status_change
    logger.debug("State has changed from #{old_state} to #{new_state}")
    
    if self.status_was == 0
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
  
  def create_event!
    @event = self.account.events.build
    @event.attributes = {
      :user       => self.user,
      :created_by => self.created_by,
      :body       => self.body,
      :subject    => self.subject,
      :duration   => self.duration,
      :date       => self.start.to_date
    }
    
    @event.save!
    self.event = @event
  end
  
end
