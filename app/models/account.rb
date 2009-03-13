require 'digest/sha1'

class Account < ActiveRecord::Base
  ReservedDomains = %w(admin www signup)
  
  #include AASM

  # #   A S S O C I A T I O N S   # #
  has_many :users,      :dependent => :destroy
  has_many :trackables, :dependent => :destroy
  has_many :events,     :dependent => :destroy, :extend => Account::EventsExtension
  has_many :labels,     :dependent => :destroy
  has_many :event_imports, :dependent => :destroy

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

  # #   C A L L B A C K S   # #
  before_validation_on_create :set_default_values
  before_save :generate_api_key
  
  #after_save :update_internal_client

  def to_s
    domain
  end
  
  def invite_code_required?
    !!Ticktock.beta?
  end
  
protected

  def generate_api_key
    self.api_key = Digest::SHA1.hexdigest("#{self.domain}#{Time.now}")
  end

  def set_default_values
    timezone ||= "UTC"
  end
  
  # def internal_client_params
  #   {
  #     :account_owner => true,
  #     :name => self.name,
  #     :rate => 0,
  #     :status => "active"
  #   }
  # end
  # 
  # def update_internal_client
  #   ic = self.internal_client || self.build_internal_client
  #   ic.update_attributes!(self.internal_client_params)
  # end

end
