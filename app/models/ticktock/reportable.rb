module Ticktock::Reportable

  def self.included(base)
    base.send(:extend,  ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
    
  end
  
  module ClassMethods
    def reporter
      @@reporter ||= Ticktock::Reporter.new(self)
    end
    
    def aggregate(column,options={})
      options.reverse_merge!({
        :using  => :count,
        :range  => ((Date.today - 8.weeks)..Date.today)
      })
      
      data = reporter.aggregate_data(column,options)
        
      #options[:range].inject(Ticktock::OrderedHash.new){ |h,d| h[d.strftime("%Y%W")] = 0; h}  
      
      data
    end
  end

end