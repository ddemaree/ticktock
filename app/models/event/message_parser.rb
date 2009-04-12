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
		params = parser_results
    
    params.symbolize_keys!
    params.reverse_merge!({
      :tags => Array(params[:tags]),
      :action => 'create'
    })
    
    HashWithIndifferentAccess.new(params)
  end
  
  def self.parse_tags(text)
    returning([]) do |tags_out|
      # Get tag(s)
      text.gsub!(/\#(?:([a-zA-Z0-9]+)|(?:"([^"]+)")|(?:'([^'"]+)')) /) do |match|
        tagname = ($1||$2||$3)
        tags_out << tagname if tagname; "##{tagname} "
      end
    end
  end
  
  def self.parse2(text)
    return nil if text.blank?
    text << " "
    
    params_out = {
      :action   => "start",
      :source   => text.dup,
      :tags     => [],
      :contexts => [],
      :body     => "",
      :starred  => false
    }
    
    # Get action
    text.sub!(/^(start|stop) */) do |match|
      params_out[:action] = $1; ""
    end
    
    # Get starred
    text.sub!(/\!starred /) do |match|
      params_out[:starred] = true; ""
    end
    
    # Get project(s)
    text.gsub!(/\@(?:([a-zA-Z0-9]+)|(?:"([^"]+)")|(?:'([^'"]+)')) /) do |match|
      params_out[:contexts] ||= []
      tagname = ($1||$2||$3)
      params_out[:contexts] << tagname if tagname; ""
    end
    
    params_out[:tags] = parse_tags(text)
    
    # Get date; slashes is the only supported format, but can now handle
    # 2-digit years (assumes 2 digits is 20**)
    text.gsub!(/([01]*\d)\/([0123]*\d)\/(19|20)*(\d{2}) /) do |match|
      mon, day, year = $1.to_i, $2.to_i, "#{$3||'20'}#{$4}".to_i
      params_out[:date] = Date.civil(year, mon, day)
      ""
    end
    
    # Get offset
    text.gsub!(/\[\-([01]*\d)\:([0-5]\d)\] /i) do |match|
      h, m = $1.to_i, $2.to_i
      s = (h * 3600) + (m * 60)
      params_out[:start] = (Time.zone.now - s)
      ""
    end
    
    # Get start time in brackets
    text.gsub!(/\[([0-2]*\d)\:([0-5]\d) *(am|pm)*\]/i) do |match|
      hour, minute = $1.to_i, $2.to_i
      hour += 12 if $3 == "pm"
      
      params =  [Time.zone.now.year, Time.zone.now.month, Time.zone.now.day]
      params += [hour, minute]
      
      params_out[:start] = Time.zone.local(*params); ""
    end
    
    # Get duration (invoked only if none of the other time matchers
    # above are not, since it has no delimiter chars)
    text.gsub!(/(\d+)\:(\d{2})(?:\:(\d{2}))* /) do |match|
      h, m, s = $1.to_i, $2.to_i, $3.to_i
      s += (h * 3600)
      s += (m * 60)
      
      params_out[:duration] = s; ""
    end
    
    params_out[:body] = text.strip
    
    params_out
  end
  
end