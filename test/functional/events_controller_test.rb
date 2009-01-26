require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  
  # #   R O U T I N G   # #
  should_route :post,   "/start",         :action => :start
  should_route :post,   "/stop",          :action => :stop
  
  should_route :get,    "/events",        :action => :index
  should_route :get,    "/events/new",    :action => :new
  should_route :post,   "/events",        :action => :create
  should_route :get,    "/events/1",      :action => :show,    :id => 1
  should_route :put,    "/events/1",      :action => :update,  :id => 1
  should_route :get,    "/events/1/edit", :action => :edit,    :id => 1
  should_route :delete, "/events/1",      :action => :destroy, :id => 1
  
  def setup
    @account   = accounts(:test_account)
    @user      = @account.users.first
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end
  
  context "on POST to :start" do
    
    context "with no active event" do
      
      context "and invalid params" do
        setup {
          start_new_event({ :event => {:body => ""}, :format => "json" })
        }
        
        should_assign_to :event
        should_respond_with 422
      end
      
      context "in HTML format" do
        setup { start_new_event }
        should_assign_to    :event
        should_respond_with 302
        should_set_current_user_on :event
    
        should "assign start time" do
          assert_not_nil assigns(:event).start
        end
      end
      
      context "in JSON format" do
        setup { start_new_event(:format => "json") }
        should_assign_to    :event
        should_set_current_user_on :event
        should_respond_with :created
        should_respond_with_content_type "application/json"
      end
    end
    
    context "with event already active" do
      setup do
        @curr_event = Factory(:event, :account => @account, :user => @user, :stop => nil, :start => 3.hours.ago)
      end
      
      context "in HTML format" do
        setup { start_new_event(:format => "html") }
        should_respond_with 302
        should_set_the_flash_to "You already have an active event"
      end
      
      context "in JSON format" do
        setup { start_new_event(:format => :json) }
        should_respond_with 406
      end
      
    end
    
  end
  
  context "on POST to :stop" do
    
    context "with an active event" do
      setup do
        @curr_event = Factory(:event, :account => @account, :user => @user, :stop => nil, :start => 3.hours.ago, :state => "active")
        stop_event
      end

      should_respond_with 302
      should_set_the_flash_to "Event stopped"
      
      should "set the stop time" do
        assert_not_nil assigns(:current_event).stop
      end
      
      should "set the state to completed" do
        assert assigns(:current_event).completed?
      end
    end
    
    context "with no active event" do
      context "in HTML format" do
        setup { stop_event }
        should_respond_with 302 
        should_set_the_flash_to "You do not have an active event"
      end
      
      context "in JSON format" do
        setup { stop_event("json") }
        should_respond_with 404
        should_respond_with_content_type "application/json"
      end
      
    end
  end

protected

  def start_new_event(params={})
    post :start, {
      :event => { :body => "Hello world" }
    }.merge(params)
  end
  
  def stop_event(format=nil)
    post :stop, {:format => format}
  end
  
end
