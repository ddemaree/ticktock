class Trackable < ActiveRecord::Base
  
  serialize_with({
    :only => [:id, :name, :nickname]
  })
  
  # #   S C O P E S   # #
  default_scope :order => "name ASC"
  named_scope :active, :conditions => "state = 'active'"
  
  # #   A S S O C I A T I O N S   # #
  belongs_to :account
  has_many :events, :foreign_key => "subject_id", :dependent => :nullify
  
  # #   V A L I D A T I O N S   # #
  validates_presence_of :account, :name
  validates_uniqueness_of :nickname, :scope => :account_id
  validates_format_of :nickname, :with => /^[a-zA-Z0-9\-_]+$/
  
  # #   C A L L B A C K S   # #
  before_validation :autofill_name_if_blank
  
  def to_s
    name || nickname || "NO NAME"
  end

protected

  def autofill_name_if_blank
    self.name ||= self.nickname
  end
  
end
