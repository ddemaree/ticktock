require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  
  # #   R O U T I N G   # #
  should_route :get,    "/account",      :action => :show
  should_route :get,    "/account/new",  :action => :new
  should_route :post,   "/account",      :action => :create
  should_route :get,    "/account/edit", :action => :edit
  should_route :put,    "/account",      :action => :update
  should_route :delete, "/account",      :action => :destroy
  
  context "on GET to :show" do
    context "with invalid domain" do
      setup do
        @request.host = "www.ticktockapp.com"
        get :show
      end
    
      should_respond_with 404
    end
    
    context "with valid domain and user" do
      setup do
        @account = Account.first#Factory(:account)
        @user    = @account.users.first
        
        @request.host = "#{@account.domain}.ticktockapp.com"
        get :show, {}, {:user_id => @user.id}
      end
      
      should_respond_with 200
    end
  
  end
  
  context "on GET to :new" do
    setup do
      @request.host = "www.ticktockapp.test"
      get :new
    end
    
    should_assign_to :account, :user
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end
  
  context "on POST to :create" do
    setup do
      @request.host = "www.ticktockapp.test"
      post :create, {
        :account => {
          :domain   => "practical",
          :name     => "My Cool Account",
          :timezone => "UTC",
          :terms_of_service => "1",
          :invite_code => "ANYOLDSTRING"
        },
        :user => {
          :name  => "David Nemesis",
          :login => "ddemaree",
          :password => "kelsey99",
          :password_confirmation => "kelsey99",
          :email => "ddemaree@gmail.com"
        }
      }
    end
    
    should_assign_to :account, :user
    should_respond_with 302
    should_redirect_to("the account page") { 'http://practical.ticktockapp.test/account' }
    
    should "save the stuff" do
      assert assigns(:account).valid?, assigns(:account).errors.full_messages
      assert assigns(:user).valid?, assigns(:user).errors.full_messages
    end
  end
  
end
