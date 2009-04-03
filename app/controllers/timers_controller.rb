class TimersController < ApplicationController
  skip_before_filter :verify_authenticity_token

  class AlreadyHasActiveEvent < Exception; end
  class NoActiveEvent < Exception; end

  rescue_from ActiveRecord::RecordInvalid, :with => :respond_on_invalid_timer

  def index
    @timers = current_user.timers.all
    
    @paused_timers = current_user.timers.paused
  end

  def create
    @timer = current_account.timers.build(params[:timer])
    @timer.body = params[:timer][:body]
    @timer.wake!
    respond_on_success
  end
  
  def wake
    @timer = current_account.timers.paused.find(params[:id])
    @timer.wake!
    respond_on_success
  end
  
  def sleep
    @timer = current_account.timers.active.find_by_id(params[:id]) ||
             current_timer
    
    @timer.sleep! if @timer
    respond_on_success
  end
  
  def finish
    @timer = current_account.timers.active.find_by_id(params[:id]) ||
             current_timer
    
    @timer.finish! if @timer
    respond_on_success
  end
  
  def destroy
    @timer = current_account.timers.active.find_by_id(params[:id]) ||
             current_timer
  
    @timer.destroy
    respond_on_success
  end
  
protected

  def respond_on_success(timer=@timer)
    respond_to do |format|
      format.html { redirect_to_param_or_default("/timers") }
      format.json { render :json => timer.to_json }
      format.xml  { render :xml  => timer.to_xml }
    end
  end
  
  def respond_on_invalid_timer(exception)
    respond_to do |format|
      format.json { render :json => exception, :status => :unprocessable_entity }
      format.xml  { render :xml  => exception, :status => :unprocessable_entity }
    end
  end

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
