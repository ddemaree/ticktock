require 'keyword_search'

module Event::Filtering
  
  def self.included(base)
    base.send(:extend, ClassMethods)
    
    base.class_eval do
      named_scope :filtered, lambda { |options| Event.options_for_filter(options) }
    end
  end

  module ClassMethods
    
    def keywords_to_options(string)
      Event::Params.from_string(string)
    end
    
    def conditions_for_trackable(value)
      {:subject_id => Event::Params.param_for_trackable(value)}
    end
    
    def options_for_filter(options={})
      if options.is_a?(String)
        return {:conditions => Event::Params.from_string(options)}
      end
      
      options.symbolize_keys!
      
      filter_keys = %w(tag tags tagged_with subject trackable)
      defaults = options.slice!(*filter_keys.collect(&:to_sym))
      
      conditions =
        options.inject({}) do |conds, kv|
          key, value = kv
          
          unless value.blank?
            case key.to_s
              when /^tag/
                tag_conditions = Event.conditions_for_tags(value)
                conds.merge!(tag_conditions)
              when "subject", "trackable"
                conds.merge!(Event.conditions_for_trackable(value))
            end
          end
          
          conds
        end
      
      {:conditions => conditions.merge(defaults)}
    end
  end
  
end