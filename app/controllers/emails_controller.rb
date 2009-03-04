class EmailsController < ApplicationController
  
  skip_before_filter :login_required, :only => [:new, :create]
  skip_before_filter :set_current_account, :only => [:new, :create]
  
  def create
    respond_to do |format|
      format.xml  { head :created }
      format.json { head :created }
    end
  end
  
end
