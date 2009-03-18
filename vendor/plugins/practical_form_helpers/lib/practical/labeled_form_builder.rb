require 'practical/labeled/form_builder'
require 'practical/labeled/form_helper'

ActionView::Helpers::FormHelper.send(:include, Practical::Labeled::FormHelper)
ActionView::Helpers::FormHelper.alias_method_chain :method_missing, :label

ActionView::Base.send(:include, Practical::Labeled::FormHelper)

ActionView::Helpers::FormBuilder.send(:include, Practical::Labeled::FormBuilder)
ActionView::Helpers::FormBuilder.alias_method_chain :method_missing, :label



# require 'action_view'
# require 'action_view/helpers'
# 
# module ActionView
#   module Helpers
#     module FormHelper
#     
#       
#       alias_method_chain :method_missing, :label
# 
#       def field_with_label(object, field_name, options={}, &block)
#         label_text = options.delete(:label)
# 
#         concat(tag(:div, {:class => 'field'}, true))
#         concat(label(object,field_name,label_text))
#         yield
#         concat('</div>')
#       end
#     end
#     
#     class FormBuilder
#       def method_missing_with_label(method_name, *args, &block)
#         if method_name.to_s =~ /^labeled_/
#           @template.send(method_name, @object, *args, &block)
#         else
#           method_missing_without_label(method_name,*args)
#         end
#       end
#       alias_method_chain :method_missing, :label
# 
#       def field_with_label(method_name,*args,&block)
#         @template.field_with_label(@object,method_name,*args,&block)
#       end
#       
#     end
#   end
# end