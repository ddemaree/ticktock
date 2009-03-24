class CalendarController < ApplicationController
  include Ticktock::DateNavigation
  
  section_name "events"
  layout 'events'
  
  def index
    session[:events_view] = {
      :controller => 'calendar',
      :week => params[:week],
      :year => params[:year],
      :month => params[:month]
    }
    
    scope = current_account.events.for_date_range(current_range)
    scope = scope.active_projects unless params[:trackable_id]
    
    @events = scope.find_and_extend
    
    respond_to do |format|
      format.html
      format.mobile { render :layout => 'default' }
    end
  end
  
  def current_view
    @current_view ||=
      if %w(date recent).include?(params[:view_by])
        params[:view_by]
      else
        'recent'
      end
  end
  helper_method :current_view

end
