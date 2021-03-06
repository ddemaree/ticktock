require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  
  def self.should_render_the_new_form
    should_assign_to :event
    should_respond_with 200
    should_render_template :new
    should_render_a_form
  end
  
  def self.should_show_events_index
    should_assign_to :events
    should_respond_with 200
    should_render_template :index
  end
  
  def self.should_have_event_count(num)
    should "have event count of #{num}" do
      assert_equal num, assigns(:events).length
    end
  end
  
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
  
  context "on GET to :index" do
    
    setup do
      %w(2009-02-02 2009-02-04 2009-02-14 2009-02-28 2009-03-28).each do |day|
        Factory(:event, :account => @account, :user => @user, :date => day.to_date, :start => nil, :stop => nil)
      end
      
      get :index
    end
    
    should_show_events_index
    
  end
  
  context "on GET to :new" do
    setup { get :new }
    should_render_the_new_form
  end
  
  context "on POST to :create" do
    context "using batch array" do
      setup { create_several_events_via_hash }
      
      should_assign_to :events
      should_respond_with 302
      should_redirect_to("the home page") { root_path }
    
      should "create multiple events" do
        assert_equal 6, assigns(:events).length
      end
    end
    
    context "with valid data" do
      setup { create_new_event }
      should_assign_to :event
      should_respond_with 302
      should_redirect_to('events index') { @controller.current_events_path_for(@event) }
      
      should "set date to today's date" do
        assert_equal Date.today, assigns(:event).date
      end
    end
    
    context "with blank body" do
      setup { create_new_event(:body => "") }
      should_render_the_new_form
    end
    
    context "with body containing duration and duration" do
      setup { create_new_event(:body => "Blah blah 1:45", :duration => "") }
      #should_render_the_new_form
      
      should_respond_with 302
      
      should "assign duration based on message" do
        assert_not_nil assigns(:event).duration
        assert_equal   1.75.hours, assigns(:event).duration
      end
    end
    
    context "with nonblank date" do
      setup { create_new_event(:date => "2007-11-03") }
      should_assign_to :event
      
      should "set date to date provided" do
        assert_equal "2007-11-03", assigns(:event).date.to_s(:db)
      end
    end
    
    context "with start time" do
      setup { create_new_event(:start => "2007-11-03 11:00:05") }
      should_assign_to :event
      
      should "set date to date provided" do
        assert_equal "2007-11-03", assigns(:event).date.to_s(:db)
      end
      
      should "set status to active" do
        assert_equal "active", assigns(:event).state
      end
    end  
  end
  
  context "on GET to :edit" do
    setup do
      @event = Factory(:event, :account => @account)
      get :edit, {:id => @event.id}
    end
    
    should_assign_to :event
    should_respond_with :success
    should_render_template :edit
    should_render_a_form
  end
  
  context "on PUT to :update" do
    setup do
      @event = Factory(:event, :account => @account)
    end
    
    context "with valid data" do
      setup do
        put :update, {:id => @event.id, :event => {:body => "BLAH BLAH BLAH"}}
      end
    
      should_respond_with :redirect
      should_redirect_to("events index") { events_path }
    end
    
    context "with blank body" do
      setup do
        put :update, {:id => @event.id, :event => {:body => ""}}
      end
    
      should_assign_to :event
      should_respond_with :success
      should_render_template :edit
      should_render_a_form
    end
  end
  
  context "on DELETE to :destroy" do
    context "via API" do
      setup do
        @event = Factory(:event, :account => @account)
        delete :destroy, {:id => @event.id, :format => 'json'}
      end

      should_assign_to :event
      should_respond_with 406
    end
    
    context "via browser" do
      setup do
        @event = Factory(:event, :account => @account)
        delete :destroy, {:id => @event.id}
      end

      should_assign_to :event
      should_respond_with :redirect
      should_redirect_to('events index') { events_path }
    end
  end

protected

  def create_new_event(params={})
    post :create, {
      :event => { :body => Faker::Lorem.paragraph }.merge(params)
    }
  end
  
  def create_several_events_via_hash(params={})
    events =
      (0..5).inject({}) do |events, x|
        events[x] = { 
          :body => Faker::Lorem.paragraph,
          :date => Date.today.to_s(:db),
          :duration => "1 hour"
        }.merge(params)
        events
      end
    
    post :create, {
      :event => events
    }
  end

  def start_new_event(params={})
    post :start, {
      :event => { :body => "Hello world" }
    }.merge(params)
  end
  
  def stop_event(format=nil)
    post :stop, {:format => format}
  end
  
end
