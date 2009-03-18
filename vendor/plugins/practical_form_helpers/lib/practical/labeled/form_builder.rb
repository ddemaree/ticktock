module Practical
  module Labeled
    module FormBuilder
      
      def method_missing_with_label(method_name, *args, &block)
        if method_name.to_s =~ /^labeled_/
          @template.send(method_name, @object_name, *args, &block)
        else
          method_missing_without_label(method_name,*args)
        end
      end
      
      def field_wrapper(method_name,*args,&block)
        @template.field_wrapper(@object_name, method_name, *args, &block)
      end
      
    end
  end
end

