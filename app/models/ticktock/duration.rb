class Ticktock::Duration
  attr_reader :raw, :hours, :minutes, :seconds
  
  def initialize(seconds)
    @raw = seconds
    @hours, @minutes, @seconds = Ticktock::Durations.time_to_units(@raw)
    self
  end
  
  def inspect
    "<Ticktock::Duration #{self.to_s}>"
  end
  
  def to_s(format=nil)
    Ticktock::Durations.duration_to_string(@raw, format)
  end
  
  def to_i
    @raw
  end
  
  def +(other)
    self.class.new(raw + other.to_i)
  end
  
  def -(other)
    self.class.new(raw - other.to_i)
  end
  
end