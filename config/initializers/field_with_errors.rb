ActionView::Base.field_error_proc = lambda { |html, instance| html }

module ActionView
  module Helpers
    module FormHelper
      
      def label_with_errors(object_name, method, text, options)
        it = InstanceTag.new(object_name, method, self, options.delete(:object))
        
        if it.object.errors.on(method)
          options.merge({:class => "hasErrors"})
        end
        
        it.to_label_tag(text, options)
      end
      alias_method_chain :label, :errors
    
    end
  end
end