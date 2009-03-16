class Ticktock::Durations
  
  def self.time_to_units(time)
    hours = (time / 3600).floor
    minutes = ((time % 3600) / 60).floor
    seconds = (time % 60).floor
    
    [hours, minutes, seconds]
  end
  
  def self.duration_to_string(time, format=nil)
    format ||= "{%Hh} {%Mm}"
    hours, minutes, seconds = time_to_units(time)
    
    format.gsub!(/(\{)?\%(\w)(?:([\w ]+)\})?/) do |match|
      optional = ($1 == "{")
      
      value =
        case $2
          when "H" then hours
          when "M" then minutes
          when "N" then minutes.to_s.rjust(2,"0")
          when "S" then seconds
          when "B" then duration_in_billable_hours(time)
          else $2
        end
        
      if optional && value == 0
        ""
      elsif $3
        value.to_s + $3.to_s
      else
        value
      end
    end
    
    format.strip
  end
  
  def self.duration_in_billable_hours(time)
    hours = (time.to_f / 3600.0)
    nearest = 0.25
    
    base_hours = (hours - (hours % nearest))
    base_hours += nearest if ((hours % nearest) > (nearest / 2))
    return base_hours
  end
  
end