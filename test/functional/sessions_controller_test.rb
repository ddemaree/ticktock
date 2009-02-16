require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users
  
  def setup
    @account      = accounts(:test_account)
    @request.host = "#{@account.domain}.ticktockapp.com"
  end

  context "on POST to :create" do
    
    should "login and redirect using good user and password" do
      post :create, :login => 'quentin', :password => 'monkey'
      assert session[:user_id]
      assert_response :redirect
    end

    should "login and not redirect using good user and bad password" do
      post :create, :login => 'quentin', :password => 'bad password'
      assert_nil session[:user_id]
      assert_response :success
    end
    
    should "login and not redirect using bad user" do
      post :create, :login => 'caddy', :password => 'monkey'
      assert_nil session[:user_id]
      assert_response :success
    end
    
    should "remember me if the box is checked" do
      @request.cookies["auth_token"] = nil
      post :create, :login => 'quentin', :password => 'monkey', :remember_me => "1"
      assert_not_nil @response.cookies["auth_token"]
    end
    
    should "not remember me if box is unchecked" do
      @request.cookies["auth_token"] = nil
      post :create, :login => 'quentin', :password => 'monkey', :remember_me => "0"
      assert @response.cookies["auth_token"].blank?
    end
    
  end
  
  context "on DELETE to :destroy" do
    setup {
      login_as :quentin
      get :destroy
    }
  
    should_respond_with 302
  
    should "log out by clearing session" do
      assert_nil session[:user_id]
    end
    
    should "delete remember token" do
      assert @response.cookies["auth_token"].blank?
    end
    
  end


  context "on GET to :new" do
    context "with login cookie" do

      should "log in if valid" do
        users(:quentin).remember_me
        @request.cookies["auth_token"] = cookie_for(:quentin)
        get :new
        assert @controller.send(:logged_in?)
      end
      
      should "fail if cookie is expired" do
        users(:quentin).remember_me
        users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
        @request.cookies["auth_token"] = cookie_for(:quentin)
        get :new
        assert !@controller.send(:logged_in?)
      end
      
      should "fail if cookie is invalid" do
        users(:quentin).remember_me
        @request.cookies["auth_token"] = auth_token('invalid_auth_token')
        get :new
        assert !@controller.send(:logged_in?)
      end
      
    end
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
