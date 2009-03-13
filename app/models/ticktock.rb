class Ticktock
  cattr_accessor :beta
  @@beta = true
  
  class << self
  
    def beta?
      !!@@beta
    end
  
  end
end