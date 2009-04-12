require 'test_helper'

class TicktockTest < ActiveSupport::TestCase

  def self.should_be_an_event
    should "be an Event" do
      assert_instance_of Event, @event
    end
  end

  def self.should_be_a_completed_event
    should_be_an_event

    should "be completed" do
      assert @event.completed?, @event.state
    end
  end

  def setup
    Date.stubs(:today).returns Date.new(2008,2,15)
    Time.stubs(:now).returns Time.utc(2008,2,15,12,0,0)
    
    Ticktock.account = @account = accounts(:test_account)
    Ticktock.user    = @user    = @account.users.first
  end
  
  context "When handling a message" do
    context "with no account or user" do
      setup do
        Ticktock.reset!
      end

      should "raise a Fuckup" do
        assert_raise Ticktock::Fuckup do
          Ticktock("anything")
        end
      end

    end
    
    context "containing only a date" do
      setup { @event = Ticktock("3/19/09 Hello world!") }

      context "the result" do
        should_be_a_completed_event
      end
    end
    
    context "containing a date and duration" do
      setup { @event = Ticktock("3/19/09 0:30 Hello world!") }

      context "the result" do
        should_be_a_completed_event
        
        should "have a duration" do
          assert_equal 30.minutes, @event.duration
        end
      end
    end
    
    context "containing a start time" do
      setup { @event = Ticktock("[9:00 am] Hello world!") }
    
      context "the result" do
        should_be_an_event
        
        should "be active" do
          assert @event.active?, @event.state
        end
      end
    end
    
    context "to stop" do
      context "with a timer active" do
        setup { 
          @current_timer = Factory(:active_event)
          @event = Ticktock("stop")
        }
        
        context "the result" do
          should_be_an_event
          
          should "be sleeping" do
            assert @event.sleeping?
          end
        end
      end
      
      context "with no timer active" do
        setup { @result = Ticktock("stop") }
        
        should "return nil" do
          assert_nil @result
        end
        
      end
      
    end
    
  end


end