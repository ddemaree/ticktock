
# No field error proc
ActionView::Base.field_error_proc = lambda { |html, instance| html }

# Serialization defaults
class ActiveRecord::Base
  
  class << self
    def serialization_defaults
      {}
    end

    def set_serialization_defaults(defaults)
      define_attr_method :serialization_defaults do
        defaults
      end
    end
    alias_method :serialize_with, :set_serialization_defaults
  end
  
  def serialization_defaults
    self.class.serialization_defaults
  end
  
  def to_json(options={})
    options.reverse_merge!(serialization_defaults)
    super(options)
  end
  
  def to_xml(options={})
    options.reverse_merge!(serialization_defaults)
    super(options)
  end
end