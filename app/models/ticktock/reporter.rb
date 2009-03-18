class Ticktock::Reporter
  attr_reader :klass
  
  def initialize(source, options={})
    @klass =
      case source
        when Class then source
        when ActiveRecord::Base then source.class
        else raise ArgumentError, "Source for Ticktock::Reporter must be an ActiveRecord model class or instance"
      end
    
    @table_name = @klass.table_name
    @date_column = (options[:date_column] || 'date')
  end
  
  def aggregate_data(column,options={})
    data = klass.all(options_for_aggregate(column,options))
    hashed_data = data.inject(Ticktock::OrderedHash.new) do |cd, obj|
      cd[obj._key] = (options[:force_numeric] ? obj._value.to_i : obj._value); cd
    end
    
    if options[:by] && [:week, :day].include?(options[:by])
      weeks = options[:range].select { |d| (d.wday == 1) }
      weeks = weeks.inject(Ticktock::OrderedHash.new) { |h,w| h[w.strftime("%Y%W")] = 0; h}
      hashed_data = weeks.merge!(hashed_data)
    end
    
    hashed_data
  end
  
  def options_for_aggregate(column, options={})
    selects = []
    selects << options[:using].to_s.upcase +
               "(#{@table_name}.#{column}) AS _value"
    
    if options[:by] && [:week, :day].include?(options[:by])
      selects << interval_function(options[:by])
      group_by = "_key"
      conditions = {@date_column.to_sym => options[:range]}
    elsif options[:by]
      selects << "#{options[:by]} AS _key"
      group_by = "_key"
    elsif options[:of] != "*"
      group_by = "#{column}"
    end
    
    {
      :select     => selects.join(", "),
      :group      => group_by,
      :conditions => conditions
    }
  end
  
  # TODO: Make this work with MySQL, not just SQLite
  def interval_function(interval=:week)
    if Rails.env.development?
      "strftime('%Y%W',#{@date_column}) AS _key"
    else
      "YEARWEEK(#{@date_column}) AS _key"
    end
  end
  
end