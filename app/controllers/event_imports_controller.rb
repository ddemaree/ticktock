class EventImportsController < ApplicationController
  
  def new
    @event_import = current_account.event_imports.new(params[:event_import])
  end
  
  def create
    #@imported_events = current_account.events.import(params[:uploaded_file])
    @event_import = current_account.event_imports.new(params[:event_import])
    @event_import.save!
    redirect_to [:mapping, @event_import]
  rescue ActiveRecord::RecordInvalid
    render :new
  end
  
  def mapping
    @event_import = current_account.event_imports.find(params[:id])
  end
  
  def update
    @event_import = current_account.event_imports.find(params[:id])
    @event_import.mapping      = params[:mapping]
    @event_import.ignore_first = params[:event_import][:ignore_first]
  
    if @event_import.can_import?
      saved, unsaved = @event_import.import!
      @imported_rows = @event_import.imported_rows
      #render :text =>  and return false
    
      flash[:message] = "Imported #{saved.length} events, skipping #{unsaved.length}"
      redirect_to root_path
    else
      render :mapping
    end
  end

end
