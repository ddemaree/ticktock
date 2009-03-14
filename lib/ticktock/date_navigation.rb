module Ticktock::DateNavigation
  
  def self.included(base)
    base.class_eval do
      helper_method :current_range, :start_date, :end_date, :params_for_date, :params_for_today, :params_for_time_frame, :params_for_next, :params_for_previous, :time_frame, :time_frame_params
    end
  end
  
  def current_range
    @date_range ||= (start_date..end_date)
  end
  
  def start_date
    Ticktock::Dates.dates_from_params(time_frame_params).first
  end
  
  def end_date
    Ticktock::Dates.dates_from_params(time_frame_params).last
  end
  
  def params_for_date(new_start_date,tf=time_frame)
    {
      :year   => (tf == "week" ? new_start_date.cwyear : new_start_date.year),
      :month  => (new_start_date.month if %w(day month).include?(tf)),
      :week   => (new_start_date.cweek if tf == "week"),
      :day    => (new_start_date.day if tf == "day"),
      :action => "index"
    }
  end
  
  def time_frame_params
    @tf_params ||= {
      :year  => (params[:year] || Time.zone.now.to_date.year).to_i,
      :month => params[:month],
      :week  => (params[:week] || (Time.zone.now.to_date.cweek if time_frame == "week")),
      :day   => params[:day],
      :time_frame => time_frame,
      :group_by => params[:group_by]
    }
    
    logger.info(@tf_params.inspect)
    
    return @tf_params
  end
  alias_method :tf_params, :time_frame_params
  
  def time_frame
    if params[:time_frame]
      params[:time_frame]
    elsif params[:date] || params[:day]
      "day"
    elsif params[:month]
      "month"
    else
      "week"
    end
  end
  
  def params_for_time_frame(tf)
    params_for_date(start_date,tf)
  end
  
  def params_for_previous
    new_start_date = start_date - 1.send(time_frame)
    params_for_date(new_start_date)
  end
  
  def params_for_next
    new_start_date = start_date + 1.send(time_frame)
    params_for_date(new_start_date)
  end
  
  def params_for_today
    params_for_date(Date.today)
  end
  
end