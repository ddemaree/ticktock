# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def page_title
    returning("") do |out|
      out << "#{@section_title} &mdash; " if @section_title
      out << "#{@page_title} &mdash; " if @page_title
      out << "TickTock"
    end
  end

  def body_id
    @body_id ||= controller.controller_name.gsub(/[^a-zA-Z0-9_-]/,"-")
  end
  
  def body_classes
    action_name =
      case controller.action_name
        when "create" then "new"
        when "update" then "edit"
        else controller.action_name
      end
    
    @body_classes ||= [action_name]
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
  
  def flash_message
    return "" unless (flash[:error] || flash[:notice] || params[:show_flash])
    
    returning("") do |output|
      output << tag(:div, {:id => "flash", :class => ("error" if (flash[:error] || params[:error]))}, true)
      output << content_tag(:p, (flash[:error] || flash[:notice] || "Lorem ipsum dolor sit amet, consectetur adipisicing elit"))
      output << "</div>"
    end
  end
  
  # def field_wrapper(object, field, &block)
  #   concat tag(:div, {:class => "field #{'hasErrors' if object.errors.on(field)}"}, true)
  #   yield
  #   concat('</div>')
  # end

end
