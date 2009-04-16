class HomeController < ApplicationController
  include Ticktock::DateNavigation
  
  def index
    session[:events_view] = {
      :controller => 'home'
    }
    
    @event = current_account.events.build
    
    @current_range = ((Time.now - 2.days).beginning_of_day..Time.now.end_of_day)
    
    recent_events_scope = current_account.events.scoped(:conditions => {:date => @current_range, :state => "completed"})
    
    @recents         = recent_events_scope.all
    @recent_count    = recent_events_scope.count
    @recent_duration = recent_events_scope.sum :duration
    
    @top_tags = current_account.labels.all :select => "labels.name, labels.id, SUM(taggings.duration) AS _count", :include => :taggings, :conditions => {:taggings => {:date => @current_range}}, :group => "labels.id", :order => "_count DESC", :limit => 5
    
  end

end
