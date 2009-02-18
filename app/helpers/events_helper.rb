module EventsHelper
  
  def event_tags(tags)
    return "" if tags.empty?
    
    tags_html = tags.collect do |tag|
      link_to "##{tag}", "javascript:void%200", :class => 'tag'
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
  
  def span_for_date(date)
    content_tag(:span, relative_date(date), :class => "date")
  end
  
  def relative_date(date)
    format =
      case date
        when Date.today then "Today"
        when Date.yesterday then "Yesterday"
        when (Date.today.beginning_of_week..Date.today) then "%A"
        #when ((2.weeks.ago.to_date)..1.week.ago.to_date) then date.strftime("Last %A")
        when (Date.today.beginning_of_year..Date.today) then "%B %e"
        else "%b %e, %Y"
      end
      
    date.strftime(format)
  end
  
  def calendar_for(events)
    return send("calendar_for_#{time_frame}", events)
  end
  
  def calendar_for_week(events)
    
  end
  
  def events_for_day(date,events=nil,&block)
    
    @events_by_day ||= @events.group_by(&:date) if @events
    events ||= (@events_by_day[date] || [])
    
    wrapper_options = {
      :class => "events_for_day #{'empty' if events.empty?}".strip,
      :id => "events_for_#{date.strftime("%Y_%m_%d")}"
    }
    
    concat(tag(:div, wrapper_options, true))
    yield events
    concat('</div>')
  end
  
  def date_header(date)
    
  end
  
end
