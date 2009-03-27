require 'digest/sha1'

class Account < ActiveRecord::Base
  ReservedDomains = %w(admin www signup)
  
  #include AASM

  # #   A S S O C I A T I O N S   # #
  has_many :users,         :dependent => :destroy
  has_one  :account_owner, :class_name => 'User',
                           :conditions => {:account_owner => true}
  has_many :trackables,    :dependent => :destroy
  has_many :timers,        :dependent => :destroy
  has_many :events,        :dependent => :destroy
  has_many :labels,        :dependent => :destroy
  has_many :event_imports, :dependent => :destroy

  has_many :taggings, :through => :labels

  # #   V A L I D A T I O N S   # #
  validates_presence_of   :name, :domain, :timezone
  validates_uniqueness_of :domain
  validates_exclusion_of  :domain,
    :in => ReservedDomains
  validates_inclusion_of  :timezone, 
    :in => ActiveSupport::TimeZone::ZONES.collect(&:name)
  validates_length_of     :domain, :within => (3..24)
  validates_acceptance_of :terms_of_service, :on => :create

  attr_accessor :invite_code
  validates_presence_of :invite_code, :if => :invite_code_required?
  validate_on_create :validate_invite_code, :if => :invite_code_required?


  # #   C A L L B A C K S   # #
  before_validation_on_create :set_default_values
  before_save :generate_api_key
  
  def to_s
    domain
  end
  
  def invite_code_required?
    !!Ticktock.beta?
  end
  
  def email
    (account_owner || users.first).try(:email)
  end
  
protected

  def validate_invite_code
    
  end

  def generate_api_key
    self.api_key = Digest::SHA1.hexdigest("#{self.domain}#{Time.now}")
  end

  def set_default_values
    self.name     ||= (self.domain || "My TickTock Account")
    self.timezone ||= "UTC"
  end
  
  

end
