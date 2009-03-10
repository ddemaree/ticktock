# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def body_id
    @body_id ||= controller.controller_name.gsub(/[^a-zA-Z0-9_-]/,"-")
  end
  
  def body_classes
    @body_classes ||= [controller.action_name]
  end
  
  def section_name
    @section_name ||= body_id
  end
  
  def link_to_unless(condition, name, options = {}, html_options = {}, &block)
    if condition
      if block_given?
        block.arity <= 1 ? yield(name) : yield(name, options, html_options)
      else
        content_tag(:span, name, html_options)
      end
    else
      link_to(name, options, html_options)
    end
  end

end
