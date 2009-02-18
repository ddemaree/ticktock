class EventImportsController < ApplicationController
  
  def create
    @imported_events = current_account.events.import(params[:uploaded_file])
  end

end
