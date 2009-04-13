require 'test_helper'

class EventsControllerTest < Ticktock::ControllerTest
  
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
  
  should_route :get,    "/events",        :action => :index
  should_route :get,    "/events/new",    :action => :new
  should_route :post,   "/events",        :action => :create
  should_route :get,    "/events/1",      :action => :show,    :id => 1
  should_route :put,    "/events/1",      :action => :update,  :id => 1
  should_route :get,    "/events/1/edit", :action => :edit,    :id => 1
  should_route :delete, "/events/1",      :action => :destroy, :id => 1
  
  should_route :post, "/events/1/sleep",    :action => :sleep, :id => 1
  should_route :post, "/events/1/wake",     :action => :wake,  :id => 1
  should_route :post, "/events/1/complete", :action => :complete, :id => 1
  
  context "on GET to :index" do
    
    setup do
      # %w(2009-02-02 2009-02-04 2009-02-14 2009-02-28 2009-03-28).each do |day|
      #   Factory(:event, :account => @account, :user => @user, :date => day.to_date, :start => nil, :stop => nil)
      # end
      
      get :index
    end
    
    should_show_events_index
  end
  
  context "on GET to :new" do
    setup { get :new }
    should_render_the_new_form
  end
  
  context "on POST to :create" do
    context "with valid data" do
      context "for a new timer" do
        setup { create_new_event }
        
        should_assign_to :event
        should_respond_with 302
        should_redirect_to("the default path") { root_path }
        
        should "create an active event" do
          assert assigns(:event).active?, assigns(:event).state
        end
      end
      
      context "for a completed event" do
        setup do
          create_new_event({
            :body     => "Hello world!",
            :date     => "2/3/2009",
            :duration => ""
          })
        end
        
        should_assign_to :event
        should_respond_with 302
        should_redirect_to("the default path") { root_path }
        
        should "create a completed event" do
          assert assigns(:event).completed?, assigns(:event).state
        end
      end
    end
    
    context "with blank body" do
      setup { create_new_event(:body => "") }
      should_render_the_new_form
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
      should_redirect_to("default") { root_path }
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
      should_respond_with 200
    end
    
    context "via browser" do
      setup do
        @event = Factory(:event, :account => @account)
        delete :destroy, {:id => @event.id}
      end

      should_assign_to :event
      should_respond_with :redirect
      should_redirect_to('default path') { root_path }
    end
  end
  
  # Methods for waking/sleeping timer events
  context "on POST to :wake" do
    setup { @request.env["HTTP_REFERER"] = "http://#{@account.domain}.ticktockapp.com/" }
    
    context "with already active event" do
      context "via browser" do
        setup { wake_event :active_event }

        should_respond_with 302
        should_redirect_to("default path") { root_url }
        should_set_the_flash_to "Can't wake an event while it's active"
      end
      
      context "via API" do
        setup { wake_event :active_event, :format => "json" }
        
        should_respond_with 422
      end
    end
    
    context "with sleeping event" do
      context "via browser" do
        setup { wake_event :sleeping_event }
        should_respond_with 302
        should_redirect_to("referer") { @request.referer }
      end
      
      context "via the API" do
        setup { wake_event :sleeping_event, :format => "json" }
        should_respond_with :success
      end
    end
  end
  
  context "on POST to :sleep" do
    setup { @request.env["HTTP_REFERER"] = "http://#{@account.domain}.ticktockapp.com/" }
    
    context "with active event" do
      context "via browser" do
        setup { sleep_event :active_event }
        should_respond_with 302
        should_redirect_to("referer") { @request.referer }
      end
      
      context "via API" do
        setup { sleep_event :active_event, :format => "json" }
        should_respond_with :success
      end
    end
    
    context "with already sleeping event" do
      context "via browser" do
        setup { sleep_event :sleeping_event }
        should_respond_with 302
        should_redirect_to("referer") { @request.referer }
        should_set_the_flash_to "Can't sleep an event while it's sleeping"
      end
      
      context "via the API" do
        setup { sleep_event :sleeping_event, :format => "json" }
        should_respond_with 422
      end
    end
  end

protected

  def wake_event(factory, options={})
    @event = Factory(factory)
    post :wake, {:id => @event.id}.merge(options)
  end
  
  def sleep_event(factory, options={})
    @event = Factory(factory)
    post :sleep, {:id => @event.id}.merge(options)
  end

  def create_new_event(params={})
    post :create, {
      :event => { :body => Faker::Lorem.paragraph }.merge(params)
    }
  end
  
end
