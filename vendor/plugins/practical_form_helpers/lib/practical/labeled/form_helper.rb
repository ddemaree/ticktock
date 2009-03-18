module Practical
  module Labeled
    module FormHelper
    
      def method_missing_with_label(method_name,*args,&block)
        if method_name.to_s =~ /^labeled_/
          options    = args.extract_options!
          label_text = options.delete(:label)
          args << options
        
          object_name = args.shift
          method = args.shift
        
          tag_name   = (options.delete(:tag) || 'div')
          field_html = send(method_name.to_s.sub(/^labeled_/,""), object_name, method,*args)
          label_html = label(object_name, method, label_text, {})
          
          if block_given?
            concat(field_wrapper(object_name,method))
            concat(label_html)
            concat(content_tag(:p, field_html))
            yield
            concat("</#{tag_name}>")
          else
            content_tag(tag_name, "#{label_html} #{field_html}", :class => "field")
          end
        else
          method_missing_without_label(method_name,*args)
        end
      end
      
      def field_wrapper(object_name, method, options={}, &block)
        tag_name    = (options.delete(:tag) || 'div')
        
        options.reverse_merge!({
          :class  => "field"
        })
        
        object = instance_variable_get("@#{object_name}")
        
        if object.errors.on(method)
          options[:class] << " hasErrors"
        end
        
        html_tag = tag(tag_name, options, true)
        
        if block_given?
          concat(html_tag)
          yield
          
          if object.respond_to?(:errors) && object.errors.on(method.to_sym)
            concat(error_messages(object, method.to_sym))
          end
          
          concat("</#{tag_name}>")
        else
          html_tag
        end
      end
      
      def error_messages(object, field)
        return "" unless object.errors.on(field)
        errors = Array(object.errors.on(field))

        returning("") do |output|
          output << tag(:ul, {:class => 'form-errors'}, true)

          human_attr_name = object.class.human_attribute_name(field.to_s)

          errors.each do |error|
            output << content_tag(:li, "#{human_attr_name} #{error}")
          end

          output << '</ul>'
        end
      end
    
    end
  end
end