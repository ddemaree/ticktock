require 'test_helper'

class EventTest < ActiveSupport::TestCase
  
  def setup
    Date.stubs(:today).returns Date.new(2008,2,15)
    Time.stubs(:now).returns Time.utc(2008,2,15,12,0,0)
  end
  
  context "Around midnight UTC" do
    setup {
      Time.stubs(:now).returns Time.utc(2008,2,15,0,0,0)
      Time.zone = "Central Time (US & Canada)"
    }
    
    context "a new Event instance" do
      setup {
        @event = Factory(:event, :date => nil, :start => nil, :stop => nil, :duration => nil, :body => "Working on a dream")
      }
      
      should "return date in local time zone" do
        assert_equal "2008-02-14".to_date, @event.date
      end
    end
    
  end
  
  context "A new Event instance" do
    should_belong_to :account
    should_belong_to :user
    should_validate_presence_of :body, :account
    
    should "require stop to be later than start" do
      event = Factory.build(:timed_event, :stop => "1997-08-24 00:02:33")
      assert !event.valid?
      assert event.errors.on(:stop)
    end
    
    context "with no date/time params" do
      setup { @event = Factory.build(:event, :start => nil, :stop => nil, :date => nil, :duration => nil) }
      
      should "be considered unsaved" do
        assert @event.unsaved?, @event.state
      end
      
      context "on save" do
        setup { assert @event.save, @event.errors.full_messages }
        
        should "be considered active" do
          assert @event.active?, @event.state
        end
      
        should "set start time to now" do
          assert_not_nil @event.start
          assert_equal Time.now, @event.start
        end
        
        should "set date to today" do
          assert_equal Date.today, @event.date
        end
        
        should "set state_changed_at to now" do
          assert_not_nil @event.state_changed_at
          assert_equal Time.now, @event.state_changed_at
        end
        
        should "have zero duration" do
          assert_equal 0, @event.duration
        end
      end # context: on save
      
    end # context: with no d/t params
    
    context "with duration" do
      
      context "only" do
        setup { @event = Factory.build(:event, :start => nil, :stop => nil, :date => nil, :duration => 4.hours) }

        context "on save" do
          setup { assert @event.save, @event.errors.full_messages }

          should "be considered completed" do
            assert @event.completed?, @event.state
          end

          should "set date to today" do
            assert_equal Date.today, @event.date
          end

        end # on save : context
      end # only : context
      
      context "and start time" do
        setup { @event = Factory.build(:event, :start => (Time.now - 6.hours), :stop => nil, :date => nil, :duration => 4.hours) }

        context "on save" do
          setup { assert @event.save, @event.errors.full_messages }

          should "be considered completed" do
            assert @event.completed?, @event.state
          end

          should "set stop time" do
            assert_equal((Time.now - 2.hours), @event.stop)
          end

        end # on save
      end # and start time
      
    end # with duration: context

  end # A new Event instance (context)
  
  context "An active Event" do
    setup { @event = Factory(:active_event) }
  
    should "be active" do
      assert @event.active?, @event.state
    end
    
    context "duration on save" do
    
      should "not be zero" do
        assert @event.duration > 0
      end

      should "be equal to the difference between start and now" do
        assert_equal 1.5.hours, @event.duration
      end
    
    end # duration context
    
    context "duration after save" do
      setup { Time.stubs(:now).returns Time.utc(2008,2,15,16,0,0) }
    
      should "be higher than at save" do
        assert @event.duration > 1.5.hours
      end
    
      should "return elapsed time" do
        assert_equal 5.5.hours, @event.duration
      end
    
    end
  
    context "on sleep" do
      setup { 
        Time.stubs(:now).returns Time.utc(2008,2,15,16,0,0)
        @event.sleep!
      }
      
      should "be sleeping" do
        assert @event.sleeping?
      end
      
      should "have updated duration" do
        assert_equal 5.5.hours, @event.duration
      end
      
      should "have updated state_changed_at" do
        assert_equal Time.now, @event.state_changed_at
      end
    end
  
  end # An active Event (context)
  
  context "A sleeping Event" do
    setup { @event = Factory(:sleeping_event) }
    
    should "be sleeping" do
      assert @event.sleeping?, @event.state
    end
    
    context "on wake" do
      setup { @event.wake! }
      
      should "not change duration" do
        assert_equal 1.hour, @event.duration
      end
      
      should "set state_changed_at" do
        assert_equal Time.now, @event.state_changed_at
      end
    end
  
    context "after wake" do
      setup {
        @event.wake!
        Time.stubs(:now).returns Time.utc(2008,2,15,14,0,0)
      }
      
      should "return elapsed time" do
        assert_equal 3.hours, @event.duration
      end
    
    end
  end

  context "Event subject/project" do
    setup do
      @event   = Factory.build(:event)
      @project = Factory(:trackable)
    end
    
    should "be assignable via trackable object" do
      @event.subject = @project
      assert_not_nil @event.subject
      assert_equal   @project, @event.subject
    end
    
    should "be assignable via trackable name" do
      @event.subject = @project.name
      assert_not_nil @event.subject
      assert_equal   @project, @event.subject
    end
    
    should "be assignable via trackable nickname" do
      @event.subject = @project.nickname
      assert_not_nil @event.subject
      assert_equal   @project, @event.subject
    end
    
    context "from different accounts" do
      setup {
        @project.account = accounts(:test_account)
      }
      
      should "quietly fail during assignment" do
        @event.subject = @project
        assert_nil @event.subject
      end
    end
  end
  
  context "Event#message" do
    context "for a completed Event" do
      setup { @event = Factory(:event, :body => "Working on a #dream", :duration => 1.5.hours) }
      
      should "include message with tags" do
        assert_match /Working on a \#dream/, @event.message
      end
      
      should "include date" do
        assert_match /\d+\/\d+\/\d{4} /, @event.message
      end
      
      should "not include duration" do
        assert_match /1\:30 /, @event.message
      end
    end
    
    context "for an active Event" do
      setup { @event = Factory(:active_event, :body => "Working on a #dream") }
      
      should "include message with tags" do
        assert_match /Working on a \#dream/, @event.message
      end
      
      should "not include date" do
        assert_no_match /\d+\/\d+\/\d{4} /, @event.message
      end
      
      should "not include duration" do
        assert_no_match /1\:30 /, @event.message
      end
    end
    
    context "for a starred Event" do
      setup { @event = Factory(:event, :body => "Working on a #dream", :duration => 1.5.hours, :starred => true) }
      
      should "include message with !starred flag" do
        assert_match /Working on a \#dream \!starred/, @event.message
      end
    end
  end
  
  context "Setting Event message" do
    context "with !starred flag" do
      setup {
        @event = Factory(:event, :body => "Working on a #dream", :duration => 1.5.hours)
        @event.message = "#{@event.message} !starred"
      }
      
      should "star the message" do
        assert @event.starred
      end
    end
    
    context "for a completed Event with no start time" do
      setup {
        @event = Factory(:event, :body => "Working on a #dream", :duration => 1.5.hours)
        @event.message = "3/22/09 0:30 Working on a #dream"
      }
      
      should "change date" do
        assert @event.date_changed?
        assert_equal Date.new(2009,3,22), @event.date
      end
      
      should "change duration" do
        assert @event.duration_changed?
        assert_equal 30.minutes, @event.duration
      end
    end
    
    context "for a completed Event with start time" do
      setup {
        @event = Factory(:event, :body => "Working on a #dream", :duration => 1.5.hours, :start => (Time.now - 2.hours))
        @event.message = "3/22/09 0:30 Working on a #dream"
        assert_not_nil @event.stop
      }
      
      should "change date" do
        assert @event.date_changed?
        assert_equal Date.new(2009,3,22), @event.date
      end
      
      should "change duration" do
        assert @event.duration_changed?
        assert_equal 30.minutes, @event.duration
      end
      
      should "change stop time" do
        assert @event.stop_changed?
      end
    end
  end
  
  
  
end
