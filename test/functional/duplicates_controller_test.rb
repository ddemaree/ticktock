require 'test_helper'

class DuplicatesControllerTest < ActionController::TestCase
  
  should_route :get, "/trackables/1/duplicates", :action => :index, :trackable_id => 1
  should_route :put, "/trackables/1/duplicates/2", :action => :update, :trackable_id => 1, :id => 2
  
  def setup
    @account   = Factory(:account)
    @user      = Factory(:user, :account => @account)
    
    @trackable = Factory(:trackable, :account => @account)
    
    3.times do |x|
      Factory(:event, :account => @account, :subject => @trackable)
    end
    
    @winning_trackable = Factory(:trackable, :account => @account)
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end
  
  context "with trackable_id" do
    context "GET to :index" do
      setup do
        get :index, {:trackable_id => @trackable.to_param}
      end
      
      should_respond_with :success
      should_render_template :index
      should_render_a_form
    end
    
    context "PUT to :update" do
      setup do
        put :update, {:trackable_id => @winning_trackable.to_param, :id => @trackable.to_param}
      end
      
      should_respond_with :redirect
      should_redirect_to("the trackables index") { trackables_path }
    
      should "have destroyed the losing trackable" do
        assert_equal 1, @account.trackables.count
      end
      
      should "have transferred loser's events to winner" do
        assert_equal 3, @winning_trackable.events.count
      end
    end
    
  end
  
end
