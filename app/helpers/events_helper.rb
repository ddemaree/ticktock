module EventsHelper
  
  def calendar_for(events)
    return send("calendar_for_#{time_frame}", events)
  end
  
  def calendar_for_week(events)
    
  end
  
end
