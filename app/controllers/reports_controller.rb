class ReportsController < ApplicationController
  
  def index
    redirect_to :action => 'top_tags'
  end
  
  def top_tags
    unless %w(frequency duration).include?(params[:by])
      params[:by] = "frequency"
    end
    
    @sorting_by = ActiveSupport::StringInquirer.new(params[:by])
    
    scope_options =
      case params[:by]
      when "frequency"
        {:order => "taggings_count DESC", :conditions => "taggings_count > 0"}
      when "duration"
        {:order => "total_duration DESC", :conditions => "total_duration > 0"}
      end
    
    @tags = current_account.labels.scoped(scope_options)
  end
  
end
