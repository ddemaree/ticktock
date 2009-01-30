require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @account   = accounts(:test_account)
    @user      = @account.users.first
    @trackable = @account.trackables.first
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end
  
  # #   R O U T I N G   # #
  should_route :get,    "/users",        :action => :index
  should_route :get,    "/users/new",    :action => :new
  should_route :post,   "/users",        :action => :create
  should_route :get,    "/users/1",      :action => :show,    :id => 1
  should_route :put,    "/users/1",      :action => :update,  :id => 1
  should_route :get,    "/users/1/edit", :action => :edit,    :id => 1
  should_route :delete, "/users/1",      :action => :destroy, :id => 1
  
  context "on GET to :new" do
    setup do
      get :new
    end
    
    should_assign_to :user
    should_render_template :new
    should_respond_with :success
    should_render_a_form
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup { create_user }
      should_assign_to :user
      should_respond_with :redirect
      should_redirect_to 'users_path'
    end
    
    context "with missing password" do
      setup { create_user(:password => "") }
      should_assign_to :user
      should_respond_with :success
      should_render_template :new
      should_render_a_form
    end
  end
  
  # # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # # Then, you can remove it from this and the units test.
  # include AuthenticatedTestHelper
  # 
  # fixtures :users
  # 
  # def test_should_allow_signup
  #   assert_difference 'User.count' do
  #     create_user
  #     assert_response :redirect
  #   end
  # end
  # 
  # def test_should_require_login_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:login => nil)
  #     assert assigns(:user).errors.on(:login)
  #     assert_response :success
  #   end
  # end
  # 
  # def test_should_require_password_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:password => nil)
  #     assert assigns(:user).errors.on(:password)
  #     assert_response :success
  #   end
  # end
  # 
  # def test_should_require_password_confirmation_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:password_confirmation => nil)
  #     assert assigns(:user).errors.on(:password_confirmation)
  #     assert_response :success
  #   end
  # end
  # 
  # def test_should_require_email_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:email => nil)
  #     assert assigns(:user).errors.on(:email)
  #     assert_response :success
  #   end
  # end
  # 

  

protected
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
  
end
