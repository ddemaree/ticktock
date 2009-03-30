require 'chronic'

class Event::Params
  attr_reader :params, :conditions
  
  def initialize(new_params={})
    @params = default_params
    @joins  = []
    
    if new_params.is_a?(String)
      @search_string = new_params
      new_params = Event::Params.from_string(new_params)
    elsif @search_string = new_params.delete(:search)
      new_params.except!(:search)
      params_from_search = Event::Params.from_string(@search_string)
      new_params = params_from_search.merge(new_params)
    end
    
    new_params.stringify_keys!
    @params = normalize_hash(new_params)
    @params
  end
  
  def default_params
    {
      :active => true
    }
  end
  
  def to_s
    params_for_search = @params.dup
    params_for_search.symbolize_keys!
    
    search_components = []
    
    if keywords = params_for_search.delete(:keywords)
      search_components << keywords #params_for_search[:keywords]
    end
    
    if starred = params_for_search.delete(:starred)
      search_components << "#{string_to_boolean(starred,nil) ? "is" : "not"}:starred"
    end
    
    params_for_search.except!(:keywords, :starred)
    
    params_for_search.each do |key, value|
      value = %{"#{value}"} if value =~ / /
      search_components << "#{key}:#{value}"
    end
    
    search_components.join(" ")
  end
  
  def method_missing(method_name,*args)
    if method_name.to_s =~ /=$/
      self[method_name.to_s.gsub(/=/,"")] = args.first
    else
      self[method_name.to_s]
    end
  end
  
  def [](key)
    @params[key.to_s]
  end
  
  def []=(key,value)
    @params.merge!(normalize_hash({key => value}))
  end
  
  def klass
    self.class
  end
  
  def normalize_hash(new_params={})
    new_params.inject({}) do |coll, kv|
      key, value = kv
      
      if key =~ klass.conditions_regexp
        coll[key] = value if !value.blank?
      elsif key =~ /trackable|subject/
        coll["project"] = value
      end
      
      coll
    end
  end
  
  def to_finder_options
    {
      :conditions => to_conditions,
      :joins => (@joins.any? ? @joins.uniq.join(" ") : nil)
    }
  end
  
  def to_conditions
    @query_options = {}
    
    @conditions = []
    
    @params.stringify_keys!
    @params.each do |k,v|
      next if v.blank?
      
      operator = k.gsub(klass.conditions_regexp, "")
      field    = $1.to_s.gsub(/_$/,"")
      operator.gsub!(/_/,"")
      operator = "is" if operator.blank?
      
      @conditions <<
        case field.to_s
          when /created|updated/
            condition_for_timestamp(field,v,operator) 
          else
            send("condition_for_#{field}", v, operator) if respond_to?("condition_for_#{field}")
        end
    end
    
    @conditions.uniq.join(" AND ")
  end
  
  def condition_for_timestamp(field,value,operator="")
    field = "#{field}_at" unless field =~ /_at$/
    operator = string_to_comparison_operator(operator)
    time = Chronic.parse(value)
  
    "#{table_name}.#{field} #{operator} #{quote time.to_s(:db)}"
  end
  
  def condition_for_duration(value,operator="")
    numeric_value = Event::TimeParser.from_string(value)
    operator = string_to_comparison_operator(operator)
    "#{table_name}.duration #{operator} #{numeric_value}"
  end
  
  def condition_for_keywords(value,operator="")
    kc = []
    phrases = []
    
    blacklisted_words = ('a'..'z').to_a + ["about", "an", "are", "as", "at", "be", "by", "com", "de", "en", "for", "from", "how", "in", "is", "it", "la", "of", "on", "or", "that", "the", "the", "this", "to", "und", "was", "what", "when", "where", "who", "will", "with", "www"]
    allowed_characters = 'àáâãäåßéèêëìíîïñòóôõöùúûüýÿ\-_\.@'
    
    # Handling for double quoted strings
    if value =~ /\"/
      value.gsub!(/(?:\"(.*?)\"\s*)/) do |match|
        phrases << $1; ""
      end
      
      value.gsub(/ +/," ").strip!
    end
    
    # Build SQL query
    phrases += value.to_s.gsub(/,;/, " ").split(/ /).uniq
    phrases.delete_if { |word| word.blank? || blacklisted_words.include?(word.downcase) }
    phrases.each do |v|
      kc << "#{table_name}.body #{operator == "not" ? "NOT LIKE" : "LIKE"} #{Event.connection.quote("%#{v}%")}"
    end
    
    "(#{kc.join(" AND ")})"
  end
  
  def condition_for_tagged(value,operator="")
    tc = []
    Label.parse(value).each do |tag|
      tc << "#{table_name}.tag #{operator == "not" ? "NOT LIKE" : "LIKE"} #{Event.connection.quote("%[#{tag}]%")}"
    end
    
    "(#{tc.join(" AND ")})"
  end
  
  def condition_for_date(value,operator="")
    date = Chronic.parse(value).to_date
    operator = string_to_comparison_operator(operator)
    "#{table_name}.date #{operator} #{Event.connection.quote date.to_s(:db)}"
  end
  
  # OPTIMIZE: Expand into a condition_for_boolean
  def condition_for_starred(value,operator=nil)
    value = string_to_boolean(value,operator)
    "#{table_name}.starred = #{quote !!value}"
  end
  
  def condition_for_project(value,operator=nil)
    if value.to_s =~ /^\d+$/
      "events.subject_id = #{value}"
    else
      @joins << trackable_join
      "(trackables.name = #{quote value} OR trackables.nickname = #{quote value})"
    end
  end
  
  def condition_for_active(value,operator=nil)
    @joins << trackable_join
    value = string_to_boolean(value,operator) ? "active" : "archived"
    "trackables.state = #{quote value}"
  end
  
  def quote(value)
    Event.connection.quote(value)
  end
  
  def trackable_join
    "LEFT OUTER JOIN trackables ON events.subject_id = trackables.id AND events.account_id = trackables.account_id"
  end
  
  def string_to_boolean(value,operator)
    if [true, false].include?(value)
      return value
    end
    
    value.strip!
    
    value =
      if value =~ /^\d$/
        !!(value.to_i > 0)
      elsif value =~ /^(?:true|false)$/
        !!(value == "true")
      else
        true
      end
    
    value = !value if operator == "not"
    value
  end
  
  def string_to_comparison_operator(operator)
    case operator.to_s
      when "after", "over" then ">"
      when "before", "under"   then "<"
      when "from" then ">="
      when "to" then "<="
      when "not" then "!="
      else "="
    end
  end
  
  def table_name
    Event.table_name
  end
  
  class << self
    
    def available_conditions
      %w(keywords duration date tagged project created updated starred active)
    end
    
    def conditions_regexp
      /(#{available_conditions.join("|")})/
    end
    
    def operators
      %w(from to before after not over under)
    end
    
    def operators_regexp
      %r{(?:_*(#{operators.collect {|o| "(?:#{o})[_$]*"}.join("|")}))}
    end
  
    def from_hash(params={})
      conditions = {}
      
      params.each do |key, value|
        case key.to_s
          when "tagged", "tag", "tags"
            conditions[:tag_has] = Label.parse(value).collect { |t| "[#{t}]"  }
        end
      end
      
      conditions
    end
    
    def param_for_trackable(v)
      case v
        when Trackable
          v.id
        when String
          Ticktock.account ? Ticktock.account.trackables.find_by_nickname(v).try(:id) : nil
        else 
          v
      end
    end

    def from_string(string)
      params = {}
      string = string.strip
      return params if string.blank?

      # Sanitize string
      string.gsub!(/\#(?:(\w+))\s*/) do |match|
        "tagged:#{$1} "
      end
      
      string.gsub!(/\@(?:(\w+))\s*/) do |match|
        "project:#{$1} "
      end

      KeywordSearch.search(string) do |with|
        with.default_keyword :body

        with.keyword :body do |values, positive|
          params[:keywords] ||= ""
          params[:not_keywords] ||= ""

          values.each do |v|
            v = %{"#{v}"} if v =~ / /
            params[positive ? :keywords : :not_keywords] << "#{v} "
          end
        end

        with.keyword :tagged do |values, positive|
          values.each do |v|
            params[positive ? :tagged : :not_tagged] = v
          end
        end
        
        with.keyword :project do |values, positive|
          values.each do |v|
            params["#{"not_" if !positive}project".to_sym] = v# unless subj_id.nil?
          end
        end

        with.keyword :is do |values|
          values.each do |value|
            case value.to_s
              when "starred" then params[:starred] = "1"
              when "not_starred" then params[:starred] = "0"
            end
          end
        end
        
        with.matcher(/^(date|duration|created|updated)/) do |key, values, positive|
          values.each do |v|
            params[key.to_sym] = v
          end
        end
        
        with.matcher(/^not/) do |key, values, positive|
          values.each do |v|
            params[key.to_sym] = v
          end
        end

      end

      params.inject({}) do |out, kv|
        k, v = kv
        out[k] = v.to_s.strip if !v.blank?; out
      end
    end
  
  end
  
end