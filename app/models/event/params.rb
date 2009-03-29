require 'chronic'

class Event::Params
  attr_reader :params, :conditions
  
  def initialize(new_params={})
    @params = {}
    @query_options = {}
    
    @conditions = []
    
    new_params.stringify_keys!
    new_params.each do |k,v|
      next if v.blank?
      
      field = k.gsub(klass.operators_regexp, "")
      @params[field] ||= {}
      
      operator = $1.to_s.gsub(/_$/,"")
      
      @params[field][operator] = v
      
      @conditions <<
        case field.to_s
          when /created|updated/
            condition_for_timestamp(field,v,operator) 
          else
            send("condition_for_#{field}", v, operator) if respond_to?("condition_for_#{field}")
        end
      
      
      
    end
    
    self
  end
  
  def [](key)
    @params[key]
  end
  
  # def []=(key,value)
  #   @params.merge!(klass.from_hash({key => value}))
  # end
  
  def klass
    self.class
  end
  
  def condition_for_timestamp(field,value,operator="")
    field = "#{field}_at" unless field =~ /_at$/
    operator = string_to_comparison_operator(operator)
    time = Chronic.parse(value)
  
    "#{field} #{operator} #{Event.connection.quote time.to_s(:db)}"
  end
  
  def condition_for_duration(value,operator="")
    numeric_value = Event::TimeParser.from_string(value)
    operator = string_to_comparison_operator(operator)
    "duration #{operator} #{numeric_value}"
  end
  
  def condition_for_keywords(value,operator="")
    kc = []
    
    blacklisted_words = ('a'..'z').to_a + ["about", "an", "are", "as", "at", "be", "by", "com", "de", "en", "for", "from", "how", "in", "is", "it", "la", "of", "on", "or", "that", "the", "the", "this", "to", "und", "was", "what", "when", "where", "who", "will", "with", "www"]
    allowed_characters = 'àáâãäåßéèêëìíîïñòóôõöùúûüýÿ\-_\.@'
    
    values = value.to_s.gsub(/,;/, " ").split(/ /).uniq
    values.delete_if { |word| word.blank? || blacklisted_words.include?(word.downcase) }
    values.each do |v|
      kc << "body #{operator == "not" ? "NOT LIKE" : "LIKE"} #{Event.connection.quote("%#{v}%")}"
    end
    
    "(#{kc.join(" AND ")})"
  end
  
  def condition_for_tagged(value,operator="")
    tc = []
    Label.parse(value).each do |tag|
      tc << "tag #{operator == "not" ? "NOT LIKE" : "LIKE"} #{Event.connection.quote("%[#{tag}]%")}"
    end
    
    "(#{tc.join(" AND ")})"
  end
  
  def condition_for_date(value,operator="")
    date = Chronic.parse(value).to_date
    operator = string_to_comparison_operator(operator)
    "date #{operator} #{Event.connection.quote date.to_s(:db)}"
  end
  
  def condition_for_starred(value,operator=nil)
    "starred = #{Event.connection.quote !!value}"
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
  
  class << self
    
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
          params[:body_has] ||= []
          params[:body_not_have] ||= []

          values.each do |v|
            params[positive ? :body_has : :body_not_have] << v
          end
        end

        with.keyword :tagged do |values, positive|
          params[:tag_has]      ||= []
          params[:tag_not_have] ||= []

          values.each do |v|
            params[positive ? :tag_has : :tag_not_have] << "[#{v}]"
          end
        end
        
        with.keyword :project do |values, positive|
          params[:subject_id_is] = []
          params[:subject_id_is_not] = []
          
          values.each do |v|
            subj_id = param_for_trackable(v)
            params["subject_id_#{positive ? "is" : "is_not"}".to_sym] << subj_id unless subj_id.nil?
          end
        end

        with.keyword :is do |values|
          values.each do |value|
            case value.to_s
              when "starred" then params[:starred] = true
            end
          end
        end

      end

      params.inject({}) do |out, kv|
        k, v = kv
        out[k] = v if !v.blank?; out
      end
    end
  
  end
  
end