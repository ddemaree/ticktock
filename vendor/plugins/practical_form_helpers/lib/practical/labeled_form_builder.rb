require 'action_view'
require 'action_view/helpers'

module ActionView
  module Helpers
    module FormHelper
    
      def method_missing_with_label(method_name,*args)
        if method_name.to_s =~ /^labeled_/
          options    = args.extract_options!
          label_text = options.delete(:label)
          args << options

          object_name = args.shift
          method = args.shift

          label_tag = label(object_name, method, label_text)
          field_tag = send(method_name.to_s.sub(/^labeled_/,""), object_name, method,*args)

          content_tag(:p, "#{label_tag}\n#{field_tag}", :class => "field")
        else
          method_missing_without_label(method_name,*args)
        end
      end
      alias_method_chain :method_missing, :label

      def field_with_label(object, field_name, options={}, &block)
        label_text = options.delete(:label)

        concat(tag(:div, {:class => 'field'}, true))
        concat(label(object,field_name,label_text))
        yield
        concat('</div>')
      end
    end
    
    class FormBuilder
      def method_missing_with_label(method_name, *args)
        if method_name.to_s =~ /^labeled_/
          @template.send(method_name, @object, *args)
        else
          method_missing_without_label(method_name,*args)
        end
      end
      alias_method_chain :method_missing, :label

      def field_with_label(method_name,*args,&block)
        @template.field_with_label(@object,method_name,*args,&block)
      end
      
    end
  end
end