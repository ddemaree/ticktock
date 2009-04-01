class Event::MessageParser
  TimeRegex = /((?:\d+:\d+(?:\:\d+)?)|(?:\d+.\d+(?:h|hr|hour)))/
  
  # Parses message string into params
  def self.parse(params={})
    if params.is_a?(String)
      params = {:body => params}
    end
    
    params[:source] = params[:body]
    
    params.merge!(Ticktock::Parser._parse(params[:body]))
    params.symbolize_keys!
    params.reverse_merge!({
      :tags => Array(params[:tags]),
      :action => 'create'
    })
    
    HashWithIndifferentAccess.new(params)
  end
  
end