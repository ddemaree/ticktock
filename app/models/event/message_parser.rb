class Event::MessageParser
  TimeRegex = /((?:\d+:\d+(?:\:\d+)?)|(?:\d+.\d+(?:h|hr|hour)))/
  
  # Parses message string into params
  def self.parse(params={})
    params.reverse_merge!({
      :body => "",
      :tags => Array(params[:tags]),
      :user_name => nil,
      :date => nil,
      :action => 'create'
    })
    
    returning(params) do |output|
      output[:source] = params[:body]
      
      return params if params[:body].nil?
      
      params[:body].sub!(/^(\w+)\b/) do |match|
        case match
          when 'start', 'stop', 'pause'
            params[:action] = $1
            ""
          else
            match
        end
      end
      
      # Unquoted tags without white space
      params[:body].scan(/\#(?:(\w+))\s*/) do |match|
        output[:tags] << $1; ""
      end

      # Quoted tags, which can contain spaces
      params[:body].scan(/\#(?:\"(.*?)\"\s*)/) do |match|
        output[:tags] << $1; ""
      end
      
      # Trackables denoted with brackets
      params[:body].sub!(/^(?:\[(.*?)\]\s*)/) do |match|
        output[:subject] = $1; ""
      end
      
      # Trackables denotes with Twitter-like @name syntax
      params[:body].gsub!(/(?:@([a-zA-Z0-9_]+))\s*/) do |match|
        output[:subject] = $1; ""
      end
      
      # Duration
      params[:body].sub!(TimeRegex) do |match|
        output[:duration] = Event::TimeParser.from_string($1); ""
      end
      
      # Date in MM/DD/YYYY
      params[:body].gsub!(/(?:^|\W)(\d{1,2})(?:\/|-)(\d{1,2})(?:\/|-)(\d{2,4})/) do |match|
        output[:date] = "#{$3}-#{$1.rjust(2,"0")}-#{$2.rjust(2,"0")}".to_date
        ""
      end
      
      # # Date using machine-readable format
      # params[:body].sub!(/\b(?:d|date)\:(?:([\d-]+)\s*)/) do |match|
      #   output[:date] = $1.to_date; ""
      # end
      # 
      # # Date using natural language
      # params[:body].sub!(/\b(?:d|date)\:(?:\"(.*?)\"\s*)/) do |match|
      #   output[:date] = Chronic.parse($1).to_date; ""
      # end

      params[:body].strip!
    end
  end
  
end