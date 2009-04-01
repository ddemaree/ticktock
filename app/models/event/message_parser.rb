class Event::MessageParser
  TimeRegex = /((?:\d+:\d+(?:\:\d+)?)|(?:\d+.\d+(?:h|hr|hour)))/
  
  # Parses message string into params
  def self.parse(params={})
    if params.is_a?(String)
      params = {:body => params}
    end
    
    # Save source
    params[:source] = params[:body]
    
    # Run body through the Ragel parser
    parser_results = Ticktock::Parser._parse(params[:body])
    
    # Do some very minor normalization
		parser_results["date"] = nil if parser_results["date"] == {}
		
		# Combine provided params with the parsed results
		params.merge!(parser_results)
    params.symbolize_keys!
    params.reverse_merge!({
      :tags => Array(params[:tags]),
      :action => 'create'
    })
    
    HashWithIndifferentAccess.new(params)
  end
  
end