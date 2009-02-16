require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
  
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
  
  # TODO: Add routing tests for calendar
  
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
    end
    
    context "for given day" do
      setup { get :index, {:day => "2", :year => "2009", :month => "2"}}
      should_show_events_index
      should_have_event_count 1
    end
    
    context "for given week" do
      setup { get :index, {:week => "6", :year => "2009" }}
      should_show_events_index
      should_have_event_count 2
    end
    
    context "for given month" do
      setup { get :index, {:month => "2", :year => "2009" }}
      should_show_events_index
      should_have_event_count 4
    end
    
  end
  
end
