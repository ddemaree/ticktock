require 'test_helper'

class Event::StatefulnessTest < ActiveSupport::TestCase

  context "On Event state change" do
    context "from active to completed" do
      setup do
        @event = Factory(:timed_event, :stop => nil)
      end
      
      should "create a punch" do
        assert_difference "@event.punches.count" do
          @event.finish!
        end
      end
      
      should "set punch duration to event's duration" do
        @event.finish!
        punch = @event.punches.first
        assert_equal @event.duration, punch.duration, "Punch duration should be #{@event.duration / 3600.0} hours, is #{punch.duration / 3600.0} hours (from #{punch.start} to #{punch.stop})"
      end
    end
    
    context "from active to sleeping" do
      setup do
        @event = Factory(:event, :stop => nil)
      end
      
      should "create a punch" do
        assert_difference "@event.punches.count" do
          @event.sleep!
        end
      end
      
      should "set state_changed_at" do
        @event.sleep!
        assert_not_nil @event.state_changed_at
      end
      
      should "set last_state_change_at" do
        @event.sleep!
        assert_not_nil @event.last_state_change_at
      end
      
      should "set punch duration" do
        @event.sleep!
        assert_not_nil @event.punches.first
        assert_not_nil @event.punches.first.duration
      end
      
    end
    
    context "from sleeping to active" do
      setup do
        @event = Factory(:timed_event, :stop => nil)
        @event.sleep!
      
        @punch = @event.punches.first
      end
      
      should "have a duration already" do
        assert_not_nil @event.duration
      end
      
      should "have nonzero duration" do
        assert @event.duration > 0, "Event started at #{@event.start}, paused at #{@event.state_changed_at} (#{(@event.start - @event.state_changed_at).abs.to_i} sec)"
      end
      
      should "have same duration as punches" do
        @duration_of_punches = @event.punches.sum(:duration)
        assert_equal @duration_of_punches, @event.duration
      end
      
      should "not update duration on wake" do
        assert_no_difference "@event.duration" do
          @event.wake!
        end
      end
      
      should "create a punch" do
        assert_difference "@event.punches.count" do
          @event.wake!
        end
      end
    end

  end

end