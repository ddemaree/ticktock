module EventsHelper
  
  def index_description
    returning("") do |output|
      if current_project
        output << "#{link_to(current_project, current_project)} &mdash; "
      end
      
      output << "Events"
      output << " tagged with &lsquo;#{params[:tags]}&rsquo;" if params[:tags]
    end
  end
  
  def event_message(message)
    output = ""
    output << message
    
    output.gsub!(/\#(?:(\w+))\s*/) do |match|
      link_to_tag($1) + " "
    end
    
    output.strip
  end
  
  def link_to_tag(tag_name)
    link_to(tag_name, events_path(:tags => tag_name), :title => "Events tagged with #{tag_name}", :class => 'tag', :rel => 'tag')
  end
  
  def event_tags(tags)
    return "" if tags.empty?
    
    tags_html = tags.collect do |tag|
      link_to_tag(tag_name)
    end.join(" ")
    
    content_tag(:span, tags_html, :class => 'tags')
  end
  
  def event_subject(subject, url=nil)
    url ||= subject
    
    returning("") do |output|
      output << tag(:strong, {:class => "#{dom_class(subject)} event_subject"}, true)
      output << link_to("#{subject}", url)
      output << '</strong>'
    end
  end
  
  def span_for_user(user)
    user_text =
      if user == current_user
        "you"
      else
        user
      end
      
    content_tag(:span, "Posted by #{user_text}", :class => "user")
  end
  


  
end
