require 'test_helper'

class TrackablesControllerTest < ActionController::TestCase
  
  # #   R O U T I N G   # #
  should_route :get,    "/trackables",        :action => :index
  should_route :get,    "/trackables/new",    :action => :new
  should_route :post,   "/trackables",        :action => :create
  should_route :get,    "/trackables/1",      :action => :show,    :id => 1
  should_route :put,    "/trackables/1",      :action => :update,  :id => 1
  should_route :get,    "/trackables/1/edit", :action => :edit,    :id => 1
  should_route :delete, "/trackables/1",      :action => :destroy, :id => 1
  
  def setup
    @account   = accounts(:test_account)
    @user      = @account.users.first
    @trackable = @account.trackables.first
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end
  
  context "when using account API key" do
    setup do
      @request.session = {}
    end
    
    context "on GET to :index" do
      setup { get :index, {:api_key => @account.api_key} }
      should_assign_to :trackables
      should_respond_with 200
      should_render_template :index
    end
    
    context "on GET to :new" do
      setup { get :new, {:api_key => @account.api_key} }
      should_respond_with 302
    end
  end
  
  context "on GET to :index" do
    setup { get :index }
    
    should_assign_to :trackables
    should_respond_with 200
    should_render_template :index
  end
  
  context "on GET to :new" do
    setup { get :new }
    
    should_assign_to :trackable
    should_respond_with 200
    should_render_template :new
    should_render_a_form
  end
  
  context "on POST to :create" do
    context "with valid data" do
      setup { create_trackable }

      should_assign_to :trackable
      should_respond_with 302
      should_redirect_to 'trackable_path(@trackable)'
    end
    
    context "with invalid data" do
      setup { create_trackable :nickname => "" }
      
      should_assign_to :trackable
      should_respond_with 200
      should_render_template :new
      should_render_a_form
    end
  end
  
  context "on GET to :show" do
    setup { get :show, :id => Fixtures.identify(:client_trackable) }
    should_assign_to :trackable
    should_respond_with 302
    should_redirect_to 'edit_trackable_path(@trackable)'
  end
  
  context "on GET to :edit" do
    setup { get :edit, :id => Fixtures.identify(:client_trackable) }
    should_assign_to :trackable
    should_respond_with 200
    should_render_template :edit
    should_render_a_form
  end
  
  context "on PUT to :update" do
    context "with valid data" do
      setup { update_trackable }

      should_assign_to :trackable
      should_respond_with 302
      should_redirect_to 'trackable_path(@trackable)'
    end
    
    context "with invalid data" do
      setup { update_trackable :nickname => "" }
      
      should_assign_to :trackable
      should_respond_with 200
      should_render_template :edit
      should_render_a_form
    end
  end
  
protected

  def create_trackable(options={})
    post :create, {
      :trackable => {
        :name => "XYZ Corp",
        :nickname => Factory.next(:domain)
      }.merge(options)
    }
  end
  
  def update_trackable(options={})
    put :update, {
      :id => Fixtures.identify(:client_trackable),
      :trackable => {
        :name => "XYZ Corp",
        :nickname => Factory.next(:domain)
      }.merge(options)
    }
  end
  
end
