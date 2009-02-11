module EventsHelper
  
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
