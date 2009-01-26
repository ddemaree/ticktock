require 'test_helper'

class EventTest < ActiveSupport::TestCase
  
  should_have_named_scope :active, :completed
  
  context "A new Event instance" do
    should_belong_to :account
    should_belong_to :user
    should_require_attributes :body, :account
    
    should "require stop to be later than start" do
      event = Factory.build(:event, :stop => "2009-01-01 00:02:33")
      assert !event.valid?
      assert event.errors.on(:stop)
    end

    should "require either date or start time" do
      event = Factory.build(:event, :start => nil, :stop => nil, :date => nil)
      assert !event.valid?, event.inspect
      assert event.errors.full_messages.include?("Date or start time must be provided"), event.errors.full_messages
    end

    should "auto populate date from start if blank" do
      event = Factory.build(:event, :date => nil)
      assert event.valid?
      assert_equal event.start.to_date, event.date
    end

    should "populate duration from start and stop" do
      event = Factory(:event)
      assert_not_nil event.duration
      assert_equal 3.hours, event.duration
    end
    
    should "be active if start is blank but stop is not" do
      event = Factory(:event, :stop => nil)
      assert event.active?
    end
    
    should "be completed if both timestamps are not blank" do
      event = Factory(:event)
      assert event.completed?
    end
    
    should "have #kind set to event" do
      event = Factory(:event)
      assert_equal "event", event.kind
    end
  end
  
  context "An extant Event instance" do
    
    context "that is active" do
      setup do
        @active_event = Factory(:event, :stop => nil)
      end
    
      should "complete when stop time is set" do
        @active_event.stop = @active_event.start + 4.hours
        assert @active_event.save
        assert @active_event.completed?
      end
      
      should "set stop time on #finish!" do
        @active_event.finish!
        assert_not_nil @active_event.stop
        assert @active_event.completed?
      end
    end
    
  end
  
end
