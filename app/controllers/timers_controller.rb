class TimersController < ApplicationController

  class AlreadyHasActiveEvent < Exception; end
  class NoActiveEvent < Exception; end

  rescue_from AlreadyHasActiveEvent, :with => :respond_on_extant_event
  rescue_from NoActiveEvent,         :with => :respond_on_no_active_event

  def create
    @timer = current_account.timers.build(params[:timer])
    @timer.wake!
    redirect_to_param_or_default
  end
  
  def wake
    @timer = current_account.timers.paused.find(params[:id])
    @timer.wake!
    redirect_to_param_or_default
  end
  
  def sleep
    @timer = current_account.timers.active.find_by_id(params[:id]) ||
             current_timer
    
    @timer.sleep! if @timer
    redirect_to_param_or_default
  end
  
  def finish
    @timer = current_account.timers.active.find_by_id(params[:id]) ||
             current_timer
    
    @timer.finish! if @timer
    redirect_to_param_or_default
  end
  
  def destroy
    @timer = current_account.timers.active.find_by_id(params[:id]) ||
             current_timer
  
    @timer.destroy
    redirect_to_param_or_default
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
  
  def respond_on_no_active_event
    respond_to do |format|
      flash[:error] = "You do not have an active event"
      format.html { redirect_to events_path }
      format.xml  { head 404 }
      format.json { head 404 }
    end
  end

end
