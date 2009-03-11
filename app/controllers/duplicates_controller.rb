class DuplicatesController < ApplicationController
  
  
  def index
    @trackable = current_account.trackables.find(params[:trackable_id])
  end
  
  def update
    @winning_trackable = current_account.trackables.find(params[:trackable_id])
    @other_trackable   = current_account.trackables.find(params[:id])
    
    Trackable.transaction do
      @other_trackable.events.update_all("subject_id = #{@winning_trackable.id}", "subject_id = #{@other_trackable.id}")
      @other_trackable.destroy
    end
    
    redirect_to trackables_path
  end

end
