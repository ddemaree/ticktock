class EventImport < ActiveRecord::Base
  MappableFields = {
    #:user     => "User",
    :subject  => "Project or client",
    :body     => "Body",
    :duration => "Duration",
    :start    => "Start time",
    :stop     => "Stop time"
  }
  
  attr_reader :imported_rows
  
  attr_accessor_with_default :ignore_first, false
  attr_accessor :mapping
  
  belongs_to :account
  validates_presence_of :account
  
  has_attached_file :source
  validates_attachment_presence :source
  delegate :to_file, :to => :source
  
  def self.mappable_fields
    returning([]) do |fields|
      fields << ["",""]
      fields << ["Do not import",""]
      fields << ["-----",""]
    end + MappableFields.collect(&:reverse)
  end
  
  def file_contents
    @file_contents ||= to_file.read
  end
  
  def rows
    file_contents.split($/).length
  end
  
  def columns
    @columns ||= from_csv.first.length
  end
  
  def from_csv
    @from_csv ||= from_csv!
  end
  
  def from_csv!
    FasterCSV.parse(file_contents, {:headers => !!ignore_first, :return_headers => false})
  end
  
  def can_import?
    if !(mapping && mapping.is_a?(Array))
      errors.add(:mapping, "not provided")
      return false
    elsif !(mapping.include?("start") or mapping.include?("date"))
      errors.add(:mapping, "must include either start time or date")
      return false
    else
      return true
    end
  end
  
  def import
    @imported_rows = []
    return @imported_rows unless can_import?
    
    
    (from_csv!).each do |csv_row|
      params = {}
      mapping.each_with_index do |field, index|
        next if field.blank?
        params[field.to_sym] = csv_row[index]
      end
      
      signature = Event.signature(params[:body], params[:date], params[:start], params[:stop])
      import_token = Event.import_token(signature)
      
      #event_row = account.events.build
      
      event_row = self.account.events.find_by_import_token(import_token) ||
                  self.account.events.build
      
      event_row.attributes = params if event_row.new_record?
      
      @imported_rows << event_row
    end
    
    @imported_rows
  end
  
  def import!
    saved_rows, unsaved_rows = [], []
    
    self.import.each do |event|
      if event.save
        saved_rows << event
      else
        unsaved_rows << event
      end
    end
    
    [saved_rows, unsaved_rows]
  end
  
end
