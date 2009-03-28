require 'test_helper'

class Time
  cattr_accessor :now
  @@now = Time.utc(2008,2,15,12,0,0)  
end

class Date
  cattr_accessor :today
  @@today = Date.new(2008,2,15)
end

class TimersControllerTest < ActionController::TestCase
  
  # #   R O U T I N G   # #
  should_route :get,    "/timers",        :action => :index
  should_route :get,    "/timers/new",    :action => :new
  should_route :post,   "/timers",        :action => :create
  should_route :get,    "/timers/1",      :action => :show,    :id => 1
  should_route :put,    "/timers/1",      :action => :update,  :id => 1
  should_route :get,    "/timers/1/edit", :action => :edit,    :id => 1
  should_route :delete, "/timers/1",      :action => :destroy, :id => 1
  
  should_route :post, "/timers/1/sleep",  :action => :sleep, :id => 1
  should_route :post, "/timers/1/wake",   :action => :wake, :id => 1
  should_route :post, "/timers/1/finish", :action => :finish, :id => 1
  
  def setup
    @account = Ticktock.account = accounts(:test_account)
    @user    = Ticktock.user    = @account.users.first
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end
  
  context "POST to :create" do
    context "with no active timer" do
      setup { post :create, {:timer => {:body => "Hello world"}}}
      
      should_assign_to    :timer
      should_respond_with :redirect
      should_redirect_to("welcome screen") { root_path }
    
      should "have one active timer" do
        assert_not_nil @controller.current_timer
        assert_equal assigns(:timer), @controller.current_timer
      end
    end
    
    context "with an active timer" do
      setup do
        @account.timers.create!(:body => "Something neat", :start => 2.hours.ago)
        post :create, {:timer => {:body => "Switching gears"}}
      end
      
      should_assign_to    :timer
      should_respond_with :redirect
      should_redirect_to("welcome screen") { root_path }
      
      should "have one active timer" do
        assert_equal 1, @account.timers.active.count
      end
      
      should "show just-created timer as current" do
        assert_equal assigns(:timer), @controller.current_timer
      end
    end
    
    # context "in JSON format" do
    #   setup { 
    #     #@request.headers["Accept"] = "application/x-json"
    #     post :create, {:timer => {:body => "Hello world"}}, :format => "json"
    #   }
    #   
    #   should_respond_with :success
    # end
  end
  
  context "POST to :sleep" do
    context "with one active timer" do
      setup do
        @timer = @account.timers.create!(:body => "Something neat", :start => 2.hours.ago)
        post :sleep, :id => @timer.id
      end
      
      should_assign_to    :timer
      should_respond_with :redirect
      should_redirect_to("welcome screen") { root_path }
      
      should "have no active timers" do
        assert_equal 0, @account.timers.active.count
      end
    end
  end
  
  context "POST to :wake" do
    context "with no active timers" do
      setup do
        create_sleeping_timer
        post :wake, :id => @timer.id
      end

      should_assign_to    :timer
      should_respond_with :redirect
      should_redirect_to("welcome screen") { root_path }

      should "have 1 active timer" do
        assert_equal 1, @account.timers.active.count
      end
    end
    
    context "with an active timer" do
      setup do
        create_sleeping_timer
        @other_timer = @account.timers.create!(:body => "Something neat", :start => 59.minutes.ago)
        post :wake, :id => @timer.id
      end
      
      should "have one active timer" do
        assert_equal 1, @account.timers.active.count
      end
      
      should "show just-created timer as current" do
        assert_equal assigns(:timer), @controller.current_timer
      end
    end
  end
  
  context "POST to :finish" do
     setup do
       @timer = @account.timers.create!(:body => "Something neat", :start => 2.hours.ago)
       post :finish, :id => @timer.id
     end
     
     should_assign_to    :timer
     should_respond_with :redirect
     should_redirect_to("welcome screen") { root_path }
     
     should "have no active timers" do
       assert_equal 0, @account.timers.active.count
     end
  end
  
protected

  def create_sleeping_timer
    @timer = @account.timers.create!(:body => "Something neat",
                                     :start => 2.hours.ago,
                                     :state_changed_at => 1.hour.ago,
                                     :state => "paused")
    
    @timer.punches.create!(:from_state => 0, :to_state => 1, :start => 2.hours.ago, :stop => 1.hour.ago, :duration => 1.hour)
  end
  
end
