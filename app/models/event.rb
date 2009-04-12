require 'digest/sha1'

class Event < ActiveRecord::Base
  
  # #   M I X I N S   # #
  include Event::Taggable
  
  # #   S C O P E S   # #
  default_scope :order => "events.date DESC, events.start DESC, events.created_at DESC"
  
  named_scope :active_projects, :joins => "LEFT OUTER JOIN trackables ON trackables.id = events.subject_id", :conditions => "trackables.id IS NULL OR trackables.state = 'active'"
  
  named_scope :active, :conditions => { :state => 'active' }
  named_scope :recent, lambda {|num| {:limit => (num||20), :conditions => {:date_gte => 2.weeks.ago}} }
  
  # #   A S S O C I A T I O N S   # #
  belongs_to :account
  belongs_to :user
  belongs_to :subject, :class_name => "Trackable"
  
  alias_method :subject_from_object=, :subject=
  
  # TODO: Require user to be assigned to a given trackable?
  # TODO: Require project to be active?
  def subject=(object_or_name)
    return nil if self.account.nil?
    
    trackable_object = 
      if object_or_name.is_a?(Trackable)
        # This presumes that the Trackable is saved and assigned to same
        # account as this event. We no longer create trackables if they
        # don't already exist
        object_or_name.account == self.account ? object_or_name : nil
      elsif object_or_name.is_a?(String)
        self.account.trackables.find_by_string(object_or_name)
      end
    
    self.subject_from_object = trackable_object
  end

  # #   V A L I D A T I O N S   # #
  validates_presence_of   :body, :account#, :user
  validate :times_are_sane
  validate :start_or_date_present
  
  # #   C A L L B A C K S   # #
  before_validation_on_create :set_initial_date_and_time
  before_save :sleep_active_timer
  
  # #   S T A T E F U L N E S S   # #
  include AASM
  
  alias_attribute    :aasm_state, :state
  aasm_initial_state :unsaved
  aasm_state         :unsaved
  aasm_state         :active
  aasm_state         :sleeping
  aasm_state         :completed
  
  aasm_event :sleep do
    # Mark state change, do recalculate hours
    transitions :from => :active, :to => :sleeping,
                :guard => :calculate_hours
  end
  
  # Should we allow completed events to be woken?
  aasm_event :wake do
    # Mark state change, but don't recalculate hours yet
    transitions :from => :sleeping, :to => :active,
                :guard => :mark_state_change
  end
  
  def initialize(*args)
    super(*args)
    self.state    ||= "unsaved"
    self.duration ||= 0
    self.account  ||= Ticktock.account
    self.user     ||= Ticktock.user
  end
  
  def duration(return_saved=false)
    return 0 if new_record?
    
    saved_duration = read_attribute(:duration)
    
    if return_saved
      saved_duration
    elsif active? && Time.now > state_changed_at
      saved_duration + (Time.now - state_changed_at).abs
    else
      saved_duration
    end
  end
  
  
  def set_body(str, parse_tags=true)
    self.tags = Event::MessageParser.parse_tags(str) if parse_tags and !str.nil?
    write_attribute(:body, str)
  end
  
  # Only parses for tags; to pass in other params, use message=
  # To set body without parsing, use set_body(str, false)
  def body=(str)
    self.set_body(str, true)
  end
  
  # Returns this event's attributes serialized into Tick Syntax.
  # 
  #   Event.new(:body => "hello", :date => "2009-03-01",
  #     :duration => 30.minutes).message
  #   => "3/1/2009 0:30 hello"
  #
  def message
    return nil if body.blank?
    
    returning("") do |output|
      output << "@#{subject.nickname} " if subject
      
      # Only returns date and time info for completed events
      if completed?
        date_string = date.strftime("%m/%d/%Y")
        output << "#{date_string} "
      
        if duration.to_i > 0
          duration_string = Ticktock::Durations.duration_to_string(duration, "%H:%N")
          output << "#{duration_string} "
        end
      end
      
      output << body
      
      if starred
        output << " !starred"
      end
    end
  end
  
  def message=(msg_text)
    return nil if msg_text.blank?
    params = Event::MessageParser.parse2(msg_text)
    self.set_attributes_from_message(params)
    params
  end
  
  # This is its own message so we can easily set up new events without
  # having to route everything through self.message=, i.e. for new
  # events/timers created from the message handler. message= is for round-
  # tripping events edited using the quick editor
  def set_attributes_from_message(params)
    # Set body without parsing, since tags have already been parsed
    self.set_body(params[:body], false)
    
    self.subject  = params[:contexts].first
    self.tags     = params[:tags]
    self.starred  = params[:starred]
    
    if new_record?
      self.date     = params[:date]
      self.start    = params[:start]
      self.duration = params[:duration]
    
    elsif self.completed?
      self.duration = params[:duration]
      self.date     = params[:date]
      
      self.stop = self.start + self.duration if self.start
    end
  end

protected

  # This only gets run on create
  def set_initial_date_and_time
    return unless unsaved?
    
    # If date and nothing else are provided, this should be
    # handled as an untimed, completed event
    if !date.blank? && start.blank? && duration.blank?
      self.state = 'completed'
    
    # If a duration is provided, treat this as a past event;
    # try to fill in information as possible, but mark completed
    elsif self.duration && self.duration > 0
      
      if self.start
        self.stop = self.start + self.duration
        self.date = self.start.to_date
      else
        self.start, self.stop = *nil
        self.date ||= Time.zone.now.to_date
      end
      
      self.state = 'completed'
      self.state_changed_at = (self.stop || self.start)
      
    # If start but no stop, handle as active timer
    elsif !start.blank? && stop.blank?
      self.state = 'active'
      self.date  = self.start.to_date
      self.calculate_hours
    
    # If no time params provided, treat as an active timer
    # to start right now
    elsif start.blank? and stop.blank? and date.blank?
      self.state =   'active'
      self.start ||= Time.zone.now
      self.date  =   self.start.to_date
      self.calculate_hours
    end
  
  end
  
  def mark_state_change
    @last_state_change_at = (self.state_changed_at || self.start)
    self.state_changed_at = Time.zone.now
  end
  
  def calculate_hours
    self.mark_state_change
    self.duration  ||= 0
    punch_duration   = (@last_state_change_at - self.state_changed_at).abs
    self.duration   += punch_duration
  end

  def start_or_date_present
    if start.blank? && date.blank?
      errors.add_to_base("Either date or start time must be provided")
    end
  end
  
  def times_are_sane
    if (start && stop) && start > stop
      errors.add :stop, "can't be earlier than start"
    end
  end
  
  def sleep_active_timer
    return true unless self.active?
    Ticktock.user.events.active(:conditions => ("id <> #{self.id}" unless self.new_record?)).each do |e|
      e.sleep! unless e == self
    end
  end

end