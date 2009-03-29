class Event::TimeParser
  
  def self.from_string(string)
    string = string.to_s
    
    hours, minutes, seconds =    
      case string
        when /^(\d{4,})$/
          # Integer longer than 4 digits is seconds
          [0,0,$1.to_i]
        when /^(\d+)$/
          # Just integer...handle as seconds?
          [$1.to_i, 0, 0]
        when /(\d+):(\d+)(?:\:(\d+))?/
          [$1.to_i, $2.to_i, $3.to_i]
        when /(\d+).(\d+)(?:h|hr|hour)?/
          sec  = ("0.#{$2}".to_f * 3600).round
          sec += ($1.to_i * 3600)
          [0, 0, sec]
        when /(?:(\d+) *(?:h|hr|hour))?(?: *(\d+) *(?:m|min|minute))?(?: *(\d+) *(?:s|sec|second))?/
          [$1.to_i, $2.to_i, $3.to_i]
      end
      
    seconds += (minutes.to_i * 60)
    seconds += (hours.to_i * 3600)
    return seconds
  end
  
  def self.to_components(raw)
    hours   = (raw / 3600.0).floor
    minutes = (raw / 60.0).floor - (hours * 60)
    seconds = (raw % 60).floor
    
    [hours, minutes, seconds]
  end

end