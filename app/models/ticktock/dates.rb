class Ticktock::Dates
  
  def self.dates_from_params(params={})
    params.symbolize_keys!
    params.reverse_merge!({
      :time_frame => "week"
    })
    
    case params[:time_frame]
      when "week"
        [sd = Date.commercial(params[:year].to_i, params[:week].to_i, 1), (sd + 6.days)]
      when "month"
        [sd = Date.new(params[:year].to_i, params[:month].to_i, 1), sd.end_of_month]
      when "day"
        [sd = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i), sd]
    end
  end
  
  def self.conditions_for_date_params(params={})
    start_date, end_date = dates_from_params(params)
    {:date => (start_date..end_date)}
  end
  
end