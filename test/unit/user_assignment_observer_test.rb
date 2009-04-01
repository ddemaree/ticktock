require 'test_helper'

class UserAssignmentObserverTest < ActiveSupport::TestCase

  def setup
    Ticktock.reset!
  end

  context "Sender#created_by" do
    setup do
      @current_user = Factory(:user)
      @account = @current_user.account
      
      Ticktock.account = @account
      Ticktock.user    = @current_user
      
      @event = Factory.build(:event)
      @event.account = @account || Factory(:account)
      @event.save
    end
    
    should "have a current user" do
      assert_not_nil UserAssignmentObserver.current_user
    end
    
    should "not be a new record" do
      @event.save
      assert !@event.new_record?, @event.errors.full_messages.inspect
    end
    
    should "not be nil" do
      assert_not_nil @event.created_by
    end
    
    should "be set to current user" do
      assert_equal @current_user, @event.created_by
    end
  end

end
