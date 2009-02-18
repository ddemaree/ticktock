class Event::Importer
  attr_reader :account, :last_import, :failed_records
  
  class MissingData < Exception; end
  
  def initialize(account)
    raise ArgumentError, "Object passed to Event::Importer must be an Account" unless account.is_a?(Account)
    @account = account
    @last_import = []
    @failed_records = []
  end
  
  def import(file_or_string,options={})
    options.reverse_merge!({
      :overwrite => false,
      :save      => true
    })
    
    @last_import = []
    
    Event.transaction do
      self.class.parse(file_or_string) do |params|
        signature = Event.signature(params[:body], params[:date], params[:start], params[:stop])
        import_token = Event.import_token(signature)
        
        event =
          self.account.events.find_by_import_token(import_token) ||
          self.account.events.build
        
        if event.new_record? or !!options[:overwrite]
          event.attributes = params
        end
        
        if event.valid? && options[:save]
          event.save
          @last_import << event
        elsif !event.valid?
          #raise "Invalid record: #{event.errors.full_messages} #{params.inspect}"
          @failed_records << event
        end        
      end
    end
    
    @last_import
  end
  
  def self.parse(file_or_string,&block)
    file_or_string = file_or_string.read unless file_or_string.is_a?(String)

    
    # unless file_or_string =~ /date,body,start,stop,hours,trackable/
    #   file_or_string = "date,body,start,stop,hours,trackable\n#{file_or_string}"
    # end
    
    events = []
    FasterCSV.parse(file_or_string, :headers => true, :header_converters => :symbol) do |row|
      yield params_for(row)
    end
  end
  
  def self.params_for(row)
    date = 
      if row[:date] && !row[:date].blank?
        row[:date].try(:to_date)
      elsif row[:start]
        row[:start].to_time.to_date
      else
        raise MissingData, "No date provided for row"
      end
    
    logger = Logger.new("#{RAILS_ROOT}/log/importing.log")
    logger.debug("\n\nAttempting to import #{row.inspect}\n\n")
    
    {
      :body    => (row[:body] || row[:task]),
      :date    => date,
      :start   => (row[:start].try(:to_time) unless row[:start].blank?),
      :stop    => (row[:stop].try(:to_time) unless row[:stop].blank?),
      :subject => row[:trackable]
    }
  end
  
end