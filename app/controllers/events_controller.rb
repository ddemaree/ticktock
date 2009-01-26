class EventsController < ApplicationController
  
  class AlreadyHasActiveEvent < Exception; end
  class NoActiveEvent < Exception; end
  
  rescue_from ActiveRecord::RecordInvalid, :with => :respond_on_invalid_event
  rescue_from AlreadyHasActiveEvent,       :with => :respond_on_extant_event
  rescue_from NoActiveEvent,               :with => :respond_on_no_active_event
  
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
  
  def current_event
    @current_event ||= current_account.events.active.first
  end

end
