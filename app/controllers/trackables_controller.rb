class TrackablesController < ApplicationController
  
  def index
    @trackables = current_account.trackables.find(:all)
  end

  def new
    @trackable = current_account.trackables.build(params[:trackable])
  end
  
  def create
    @trackable = current_account.trackables.build(params[:trackable])
    
    respond_to do |format|
      if @trackable.save
        format.html {
          flash[:message] = "Trackable saved!"
          redirect_to @trackable
        }
        format.xml  { render :xml  => @trackable, :status => :created, :location => @trackable }
        format.json { render :json => @trackable, :status => :created, :location => @trackable }
      else
        flash.now[:error] = "Oops, the project could not be saved. Please fix the errors below and try again."
        
        format.html { render :action => "new" }
        format.xml  { render :xml  => @trackable.errors, :status => :unprocessable_entity }
        format.json { render :json => @trackable.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def show
    @trackable = current_account.trackables.find(params[:id])
    redirect_to [:edit, @trackable]
  end
  
  def edit
    @trackable = current_account.trackables.find(params[:id])
  end
  
  def update
    @trackable = current_account.trackables.find(params[:id])
  
    respond_to do |format|
      if @trackable.update_attributes(params[:trackable])
        format.html { redirect_to @trackable }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @trackable.errors, :status => :unprocessable_entity }
        format.json { render :json => @trackable.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  def destroy
    @trackable = current_account.trackables.find(params[:id])
  end
  
protected

  # Allow global API access for read only
  def authorized?(action = action_name, resource = nil)
    case action
      when "index", "show"
        logged_in_via_account_api_key? or logged_in?
      else
        logged_in?
    end
  end

end
