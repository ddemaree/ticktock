class Event::MessageParser
  TimeRegex = /((?:\d+:\d+(?:\:\d+)?)|(?:\d+.\d+(?:h|hr|hour)))/
  
  # Parses message string into params
  def self.parse(params={})
    params.reverse_merge!({
      :body => "",
      :tags => Array(params[:tags]),
      :subject => nil,
      :user_name => nil,
      :date => Date.today
    })
    
    returning(params) do |output|
      output[:source] = params[:body]
      
      return params if params[:body].nil?
      
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