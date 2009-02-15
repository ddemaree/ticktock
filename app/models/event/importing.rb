require 'faster_csv'

module Event::Importing
  
  def self.included(base)
    base.send(:extend, ClassMethods)
    
    base.class_eval do
      before_validation :set_import_token
    end
  end
  
  module ClassMethods
    
    def import(file_or_string,save_records=false)
      return self.import(file_or_string.read) unless file_or_string.is_a?(String)
      
      unless file_or_string =~ /start,stop,hours,trackable,task/
        file_or_string = "start,stop,hours,trackable,task\n#{file_or_string}"
      end
      
      events = []
      FasterCSV.parse(file_or_string, :headers => true, :header_converters => :symbol) do |row|
        puts row.inspect
        
        params = {
          :body    => row[:task],
          :start   => row[:start],
          :stop    => row[:stop],
          :subject => row[:trackable]
        }
        
        
        if respond_to?(:build)
          events << build(params)
        end
      
      end
      
      events
    end
    
    def import!(file_or_string)
      import(file_or_string,true)
    end
    
    def signature(body,date,start=nil,stop=nil)
      %{#{body}:#{date}:#{start}:#{stop}:}
    end

    def import_token(signature)
      Digest::SHA1.hexdigest(signature)
    end
  
  end
  
  def set_import_token
    self.import_token = Event.import_token(self.signature)
  end
  
  def signature
    self.class.signature(body,date,start,stop)
  end
  
end