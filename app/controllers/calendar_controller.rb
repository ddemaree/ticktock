class CalendarController < ApplicationController
  include Ticktock::DateNavigation
  
  def index
    @events = current_account.events.for_date_range(current_range)
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
