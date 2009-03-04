class EventSet < Array
  
  class MetaProxy
    attr_accessor :name, :duration, :count
    
    def initialize(name)
      @name = name
      @duration = 0
      @count = 0
    end
    
    def to_s
      name
    end
    
    def inspect
      "#{name} (#{self.class})"
    end
    
    def <=>(other)
      (name <=> other.name)
    end
  end
  
  class TagProxy < MetaProxy; end
  
  class TrackableProxy < MetaProxy
    attr_accessor :trackable
    
    def initialize(trackable)
      @trackable  = trackable
      @name     = (@trackable.to_s)
      @duration = 0
      @count    = 0
    end
    
    def to_param
      @trackable.id
    end
  end
  
  def initialize(results)
    self.replace results
  end
  
  def total_duration
    self.sum { |e| e.duration.to_i  }
  end
  
  def count
    self.length
  end
  
  def tags
    inject({}) do |tags, event|
      event.tags.each do |tag|
        #tags[tag] ||= {:duration => 0, :count => 0}
        tags[tag] ||= TagProxy.new(tag)
        tags[tag].duration += event.duration
        tags[tag].count    += 1
      end
      
      tags
    end.values
  end
  
  def trackables
    inject({}) do |trackables, event|
      if event.subject
        trackables[event.subject] ||= TrackableProxy.new(event.subject)
        trackables[event.subject].duration += event.duration
        trackables[event.subject].count    += 1
      end
      
      trackables
    end.values
  end
  
end