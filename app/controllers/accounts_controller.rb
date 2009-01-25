class AccountsController < ApplicationController
  
  skip_before_filter :login_required, :only => [:new, :create]
  skip_before_filter :set_current_account, :only => [:new, :create]
  
  def new
    initialize_user_and_account
  end
  
  # POST /accounts
  # POST /accounts.xml
  def create    
    initialize_user_and_account
    
    respond_to do |format|
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to :action => "show", :host => account_host(@account) }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end
  
protected

  def initialize_user_and_account
    @account = Account.new(params[:account])
    @user    = @account.users.build(params[:user])
    @user.account = @account
  end

end
