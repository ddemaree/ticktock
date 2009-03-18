module Ticktock::Reportable

  def self.included(base)
    base.send(:extend,  ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
    
  end
  
  module ClassMethods
    
    def aggregate(column,options={})
      reporter = Ticktock::Reporter.new(self)
      
      options.reverse_merge!({
        :using  => :count,
        :range  => ((Date.today - 8.weeks)..Date.today),
        :force_numeric => true
      })
      
      data = reporter.aggregate_data(column,options)
      data
    end
  end

end