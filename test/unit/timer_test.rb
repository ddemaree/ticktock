require 'test_helper'

class Time
  cattr_accessor :now
  @@now = Time.utc(2008,2,15,12,0,0)  
end

class Date
  cattr_accessor :today
  @@today = Date.new(2008,2,15)
end

class TimerTest < ActiveSupport::TestCase
  
  def teardown
    Time.now = Time.utc(2008,2,15,12,0,0)
  end
  
  should_belong_to :account
  should_belong_to :user
  should_belong_to :subject
  should_belong_to :created_by
  should_belong_to :event
  
  should_have_named_scope :paused
  should_have_named_scope :active
  should_have_named_scope :completed
  should_have_named_scope :open
  
  context "a new Timer instance" do
    setup { @timer = Factory.build(:timer, :start => nil) }
  
    should "have aasm_state" do
      assert_equal "active", @timer.aasm_state
    end
    
    should "respond to aasm state query method" do
      assert @timer.active?
    end
  
    should "set numeric state from aasm_state" do
      @timer.aasm_state = "completed"
      assert_equal 2, @timer.status
    end
    
    should "set initial start time to current time" do
      @timer.save
      assert_not_nil @timer.start
      assert_equal Time.zone.now, @timer.start
    end
    
  end
  
  context "On timer state change" do
    context "from active to completed" do
      setup do
        @timer = Factory(:timer)
      end
      
      should "create a punch" do
        assert_difference "@timer.punches.count" do
          @timer.finish!
        end
      end
      
      should "set punch duration to event's duration" do
        @timer.finish!
        punch = @timer.punches.first
        
        assert_not_nil punch
        assert_equal @timer.duration, punch.duration, "Punch duration should be #{@timer.duration / 3600.0} hours, is #{punch.duration / 3600.0} hours (from #{punch.start} to #{punch.stop})"
      end
      
      should "create event" do
        assert_difference "Event.count" do
          @timer.finish!
        end
      end
    end
    
    context "from active to sleeping" do
      setup do
        @timer = Factory(:timer)
      end
      
      should "create a punch" do
        assert_difference "@timer.punches.count" do
          @timer.sleep!
        end
      end
      
      should "set state_changed_at" do
        @timer.sleep!
        assert_not_nil @timer.state_changed_at
      end
      
      should "set last_state_change_at" do
        @timer.sleep!
        assert_not_nil @timer.last_state_change_at
      end
      
      should "set punch duration" do
        @timer.sleep!
        assert_not_nil @timer.punches.first
        assert_not_nil @timer.punches.first.duration
      end
      
      should "show 2 hours elapsed" do
        @timer.sleep!
        assert_equal 2.hours, @timer.duration
      end
      
    end
    
    context "from sleeping to active" do
      setup do
        @timer = Factory(:timer)
        @timer.sleep!
      
        @punch = @timer.punches.first
        Time.now = Time.utc(2008,2,15,15,0,0)
      end
      
      should "have a duration already" do
        assert_not_nil @timer.duration
      end
      
      should "return elapsed time" do
        @timer.wake!
        
        # 2 hours have passed
        Time.now = Time.utc(2008,2,15,17,0,0)
        assert @timer.active?
        assert_equal 4.hours, @timer.elapsed
        
        # Then 6 hours have passed
        Time.now = Time.utc(2008,2,15,21,0,0)
        assert_equal 8.hours, @timer.elapsed
      end
      
      should "have nonzero duration" do
        assert @timer.duration > 0, "Event started at #{@timer.start}, paused at #{@timer.state_changed_at} (#{(@timer.start - @timer.state_changed_at).abs.to_i} sec)"
      end
      
      should "have same duration as punches" do
        @duration_of_punches = @timer.punches.sum(:duration)
        assert_equal @duration_of_punches, @timer.duration
      end
      
      should "not update duration on wake" do
        assert_no_difference "@timer.duration" do
          @timer.wake!
        end
      end
      
      should "create a punch" do
        assert_difference "@timer.punches.count" do
          @timer.wake!
        end
      end
      
      should "sleep again after 2 more hours" do
        @timer.wake!
        Time.now = Time.utc(2008,2,15,17,0,0)
        @timer.sleep!
        assert_equal 4.hours, @timer.duration, @timer.state_changed_at
      end
    end

  end
  
end
