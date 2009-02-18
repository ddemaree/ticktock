class Event::Importer
  attr_reader :account, :last_import
  
  def initialize(account)
    raise ArgumentError, "Object passed to Event::Importer must be an Account" unless account.is_a?(Account)
    @account = account
    @last_import = []
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
        end
        
        @last_import << event
        
      end
    end
    
    @last_import
  end
  
  def self.parse(file_or_string,&block)
    #return self.parse(file_or_string.read) unless file_or_string.is_a?(String)
    
    file_or_string = file_or_string.read unless file_or_string.is_a?(String)
    
    unless file_or_string =~ /date,body,start,stop,hours,trackable/
      file_or_string = "date,body,start,stop,hours,trackable\n#{file_or_string}"
    end
    
    events = []
    FasterCSV.parse(file_or_string, :headers => true, :header_converters => :symbol) do |row|
      params = {
        :body    => row[:body],
        :date    => row[:date].to_date,
        :start   => row[:start].to_time,
        :stop    => row[:stop].to_time,
        :subject => row[:trackable]
      }
      
      yield params
    
    end
  end
  
end