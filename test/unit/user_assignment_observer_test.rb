require 'test_helper'

class UserAssignmentObserverTest < ActiveSupport::TestCase

  context "Sender#created_by" do
    setup do
      @current_user = Factory(:user)
      @account = @current_user.account
      UserAssignmentObserver.current_user = @current_user
      
      @event = Factory.build(:event)
      @event.account = @account || Factory(:account)
      @event.save
    end
    
    should "not be nil" do
      assert_not_nil @event.created_by
    end
    
    should "be set to current user" do
      assert_equal @current_user, @event.created_by
    end
  end

end
