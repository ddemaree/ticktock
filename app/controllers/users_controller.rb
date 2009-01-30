# TODO: Refactor to be user manager, not signup form

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  

  # render new.rhtml
  def new
    @user = current_account.users.build(params[:user])
  end
 
  def create
    @user = current_account.users.build(params[:user])
    @user.save!
    flash[:message] = "#{@user.name}'s account was created"
    redirect_to users_path
  
  rescue ActiveRecord::RecordInvalid
    flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
    render :new
    
  end
end
