module CalendarHelper
  
  def month_grid
    start_date_for_grid = start_date.beginning_of_month.beginning_of_week
    end_date_for_grid   = start_date.end_of_month.end_of_week
    
    grid_range = (start_date_for_grid..end_date_for_grid)
    
    returning("") do |output|
      output << tag(:table, {:class => "month_grid"}, true)
      
      day_ths = %w(M T W T F S S).collect {|d| content_tag(:th, d) }.join("")
      output << content_tag(:tr, day_ths, :class => "header_row")
      
      grid_range.to_a.in_groups_of(7) do |week_row|
        output << tag(:tr, {:class => 'week'}, true)
        
        week_row.each do |day|
          event_count = current_account.events.count :conditions => {:date => day}
          
          classes_for_day = ['day']
          classes_for_day << day.strftime("%a").downcase
          classes_for_day << 'today' if day == Date.today
          classes_for_day << 'currentmonth' if (day.month == start_date.month)
          
          classes_for_day << 'in_range' if current_range.include?(day)
          
          classes_for_day << 
            if event_count == 0
              'no-events'
            elsif event_count >= 4
              'events-more'
            else
              "events-#{event_count}"
            end
          
          output << tag(:td, {:id => "day_#{day.strftime("%Y%m%d")}", :class => classes_for_day.join(" ")}, true)
          output << content_tag(:span, day.day, :class => 'day_of_month')
          output << content_tag(:span, event_count, :class => 'event_count') if event_count > 0
          output << '</td>'
          
        end
        
        output << '</tr>'
      end
      
      output << "</table>"
    end
  end
  
end
