class EmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required, :only => [:new, :create]
  skip_before_filter :set_current_account, :only => [:new, :create]
  
  def create
    message = Email.parse(params[:email])
    logger.info(message.inspect)
    
    if message.acceptable?
      message.accept!
      
      respond_to do |format|
        format.xml  { head :created }
        format.json { head :created }
      end
    else
      message.reject!
      
      respond_to do |format|
        format.xml  { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
    
  end
  
end
