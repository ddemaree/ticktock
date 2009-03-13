module AccountsHelper
  
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
