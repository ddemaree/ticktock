class Label < ActiveRecord::Base
  include Ticktock::Reportable
  
  #provides_report :frequency, :aggregator => :count, :of => :taggings_count
  
  validates_presence_of :account, :name
  validates_format_of :name, :with => /[\w ]+/
  
  belongs_to :account
  has_many :taggings, :dependent => :destroy
  
  def update_stats!
    self.total_duration = self.taggings.sum(:duration)
    self.taggings_count = self.taggings.count
    self.save!
  end
  
  def to_s
    name
  end
  
  def frequency
    taggings.aggregate :id, :by => :week
  end
  
  def time_spent
    taggings.aggregate :duration, :by => :week, :using => :sum
  end
  
  def self.serialize(tags_as_array)
    tags_as_array.map { |t| "[#{t}]" }.join(" ")
  end
  
  def self.unserialize(tags_as_string)
    tags_as_string.split(/\] *\[/).map {|t| t.gsub(/[\[\]]/, "") }
  end
  
  def self.parse(list)
    
    # Add support for arrays, which would be coming from a JS tag builder
    if list.is_a?(Array)
      return list.collect(&:strip).delete_if(&:empty?).uniq
    end
    
    # If tag list includes commas, use those as the delimiter
    if list =~ /, */
      return list.split(/, */).delete_if(&:empty?).uniq
    end
    
    tag_names = []

    # first, pull out the quoted tags
    list.gsub!(/\"(.*?)\"\s*/ ) { tag_names << $1; "" }

    # then, replace all commas with a space
    list.gsub!(/,/, " ")

    # then, get whatever's left
    tag_names.concat list.split(/\s/)

    # strip whitespace from the names
    tag_names = tag_names.map { |t| t.strip }

    # delete any blank tag names
    tag_names = tag_names.delete_if { |t| t.empty? }
    
    return tag_names
  end
  
  def on(taggable)
    #taggings.create :taggable => taggable
    taggings.create :event => taggable
  end
  
end
