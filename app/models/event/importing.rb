require 'faster_csv'

module Event::Importing
  
  def self.included(base)
    base.send(:extend, ClassMethods)
    
    base.class_eval do
      before_validation :set_import_token
    end
  end
  
  module ClassMethods
    
    def signature(body,date,start=nil,stop=nil)
      start = start.to_time.strftime("%Y%m%d%I%M%S%Z") unless start.nil?
      stop  = stop.to_time.strftime("%Y%m%d%I%M%S%Z")  unless stop.nil?
      
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