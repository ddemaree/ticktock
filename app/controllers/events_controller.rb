class EventsController < ApplicationController
  
  class AlreadyHasActiveEvent < Exception; end
  class NoActiveEvent < Exception; end
  
  rescue_from ActiveRecord::RecordInvalid, :with => :respond_on_invalid_event
  rescue_from AlreadyHasActiveEvent,       :with => :respond_on_extant_event
  rescue_from NoActiveEvent,               :with => :respond_on_no_active_event
  
  def index
    @events = current_account.events.paginate(:all, :per_page => (params[:per_page] || 20), :page => params[:page])
    
    #@search = current_account.events.new_search(params[:search])
    #@events = @search.all
    
    respond_to do |format|
      format.html
      format.xml  { render :xml  => @events }
      format.json { render :json => @events }
    end
  end
  
  def new
    @event = current_account.events.build(params[:event])
    
    respond_to do |format|
      format.html
      format.xml  { render :xml  => @event }
      format.json { render :json => @event }
    end
  end
  
  def create
    @event = current_account.events.build(params[:event])
    @event.save!
    
    
    respond_to do |format|
      flash[:notice] = 'Article was successfully created.'
      
      format.html { redirect_to events_path }
      format.js   {
        headers["X-JSON"] = @event.to_json
        render :partial => 'list_item', :locals => {:event => @event }, :status => :created
      }
      format.xml  { render :xml  => @event, :status => :created, :location => @event }
      format.json { render :json => @event, :status => :created, :location => @event }
    end
  
  rescue ActiveRecord::RecordInvalid
    respond_on_failed_create @event
    
  end
  
  def edit
    @event = current_account.events.find(params[:id])
  end
  
  def update
    @event = current_account.events.find(params[:id])
    @event.update_attributes!(params[:event])
    
    respond_to do |format|
      flash[:notice] = 'Event was successfully created.'
      
      format.html { redirect_to events_path }
      format.xml  { head :ok }
      format.json { head :ok }
    end

  rescue ActiveRecord::RecordInvalid
    respond_on_failed_create @event
  end
  
  def destroy
    @event = current_account.events.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_path) }
      format.xml  { head :ok }
      format.atom { head :ok }
    end
  end
  
  def start
    raise AlreadyHasActiveEvent unless current_event.nil?
    
    @event = current_account.events.build(params[:event])
    @event.wake
    @event.save!
    
    respond_to do |format|
      format.html { redirect_to events_path and return }
      format.xml  { render :xml => @event,  :status => :created, 
                           :location => @event }
      format.json { render :json => @event, :status => :created, 
                           :location => @event }
    end
  end

  def stop
    raise NoActiveEvent unless current_event
    
    current_event.finish!
    
    respond_to do |format|
      flash[:message] = "Event stopped"
      format.html { redirect_to events_path and return }
      format.xml  { head :ok }
      format.json { head :ok }
    end
    
  end
  
protected
  
  def respond_on_extant_event
    respond_to do |format|
      flash[:error] = "You already have an active event"
      format.html { redirect_to events_path and return }
      format.xml  { render :xml  => current_event, :status => 409 }
      format.json { render :json => current_event, :status => 409 }
    end
  end
  
  def respond_on_invalid_event
    respond_to do |format|
      format.html { redirect_to events_path and return }

      format.xml  { render :xml => @event.errors,  :status => :unprocessable_entity, :location => @event }

      format.json  { render :json => @event.errors,  :status => :unprocessable_entity, :location => @event }
    end
  end
  
  def respond_on_no_active_event
    respond_to do |format|
      flash[:error] = "You do not have an active event"
      format.html { redirect_to events_path }
      format.xml  { head 404 }
      format.json { head 404 }
    end
  end
  
  def respond_on_failed_create(object=@event)
    respond_to do |format|
      format.html { render :action => (object.new_record? ? "new" : "edit") }
      format.xml  { render :xml  =>  object.errors, :status => :unprocessable_entity }
      format.json { render :json =>  object.errors, :status => :unprocessable_entity }
    end
  end

end
