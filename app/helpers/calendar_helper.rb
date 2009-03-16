module CalendarHelper
  
  def time_to_units(time)
    return Ticktock::Durations.time_to_units(time)
  end
  
  def duration_to_string(time, format=nil)
    return Ticktock::Durations.duration_to_string(time,format)
  end
  
  def duration_in_words(time,options={})
    return Ticktock::Durations.duration_to_string(time,"{%H hours} {%M minutes}")
  end
  
  def duration_in_billable_hours(time)
    return Ticktock::Durations.duration_in_billable_hours(time)
  end
  
  def trackables_colors
    %w(ff0000 ffcc00 88aa00 0088dd 9900aa cccccc)
  end
  
  def tag_class(time)
    returning('') do |className|
      className <<
        case time
          when (0..60.minutes) then 'tag1'
          when (0..3.hours) then 'tag2'
          when (0..6.hours) then 'tag3'
          when (0..12.hours) then 'tag4'
          when (0..24.hours) then 'tag5'
          else 'tag6'
        end
    end
  end
  
  def trackables_pie_chart(dataset)
    total = @events.total_duration
    trackables = dataset[0,5]
    
    pie = GChart.pie do |p|
      p.data = trackables.collect(&:duration)
      
      if dataset.length > 5
        p.data << dataset[5,100].sum(&:duration)
      end
      
      #p.legend = trackables.sort.collect(&:name)
      p.colors = *trackables_colors.first(p.data.length)
      p.width = 96
      p.height = 96
      p.extras = {:chma => "0,0,0,0"}
      p.entire_background = 'f5f5f5'
    end
    
    image_tag pie.to_url
  end
  
  def span_for_date(date)
    content_tag(:span, relative_date(date), :class => "date")
  end
  
  def relative_date(date)
    return "" if date.nil?
    
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
  rescue
    ""
  end
  
  
  # FIXME: Need tests for range_description*
  def range_description
    if respond_to?("range_description_for_#{time_frame}")
      return send("range_description_for_#{time_frame}")
    end
    
    start_date.to_s(:long)
  end
  
  def range_description_for_week
    returning("") do |output|
      if start_date.year != end_date.year
        output =
          start_date.strftime("%b %e, %Y") +
          "&mdash;" +
          end_date.strftime("%b %e, %Y")
      
        return output
      end
      
      output <<
        if start_date.month != end_date.month
          start_date.strftime("%b %e") +
          "&mdash;" +
          end_date.strftime("%b %e")
        else
          "#{start_date.strftime("%B")} #{start_date.day}&mdash;#{end_date.day}"
        end
      
      output << ", #{end_date.year}"
    end
  end
  
  def month_grid(grid_date=start_date)
    start_date_for_grid = grid_date.beginning_of_month.beginning_of_week
    end_date_for_grid   = grid_date.end_of_month.end_of_week
    
    grid_range = (start_date_for_grid..end_date_for_grid)
    
    returning("") do |output|
      output << tag(:table, {:class => "month_grid"}, true)
      
      output << %{<tr class="month_name"><th colspan="7">#{grid_date.strftime('%B %Y')}</th></tr>}
      
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
