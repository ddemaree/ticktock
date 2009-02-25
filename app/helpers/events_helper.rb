module EventsHelper
  
  def event_message(message)
    message.gsub!(/\#(?:(\w+))\s*/) do |match|
      link_to_tag($1) + " "
    end
    
    message.strip
  end
  
  def link_to_tag(tag_name)
    link_to(tag_name, "javascript:void%200", :title => "Events tagged with #{tag_name}", :class => 'tag', :rel => 'tag')
  end
  
  def event_tags(tags)
    return "" if tags.empty?
    
    tags_html = tags.collect do |tag|
      link_to_tag(tag_name)
    end.join(" ")
    
    content_tag(:span, tags_html, :class => 'tags')
  end
  
  def event_subject(subject)
    returning("") do |output|
      output << tag(:strong, {:class => "#{dom_class(subject)} event_subject"}, true)
      output << link_to("#{subject}", subject)
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
