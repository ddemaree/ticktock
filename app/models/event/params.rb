class Event::Params
  attr_reader :params, :search_string
  
  def initialize(params={})
    @search_string = params.is_a?(String) ? params : params.delete(:search)
    @params = {}
    
    if @search_string
      @params.merge! klass.from_string(@search_string)
    end
    
    klass.from_hash(params).each do |key, value|
      if @params[key]
        @params[key] += value
      end
    end
  end
  
  def [](key)
    @params[key]
  end
  
  def []=(key,value)
    @params.merge!(klass.from_hash({key => value}))
  end
  
  def klass
    self.class
  end
  
  class << self
  
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