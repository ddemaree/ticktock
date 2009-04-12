require 'test_helper'

class Event::NewParserTest < ActiveSupport::TestCase
  
  def setup
    Date.stubs(:today).returns Date.new(2008,2,15)
    Time.stubs(:now).returns Time.utc(2008,2,15,12,0,0)
  end
  
  context "Event::MessageParser.parse2" do
    context "given message containing projects" do
      setup do
        @message = "@project1 @client1 Hello world"
        @params  = Event::MessageParser.parse2(@message)
      end
      
      should "return array containing project names" do
        assert_contains @params[:contexts], "client1", "project1" 
      end
      
      should "preserve message content" do
        assert_equal "Hello world", @params[:body]
      end
    end
    
    context "given message containing tags" do
      setup do
        @message = "@project1 @client1 Hello world #billable"
        @params  = Event::MessageParser.parse2(@message)
      end
      
      should "return array containing tag names" do
        assert_contains @params[:tags], "billable" 
      end
      
      should "return array containing project names" do
        assert_contains @params[:contexts], "client1", "project1" 
      end
      
      should "preserve message content including tags" do
        assert_equal "Hello world #billable", @params[:body]
      end
    end
    
    context "given message containing quoted tags" do
      setup do
        @message = "@Hello world #'billable stuff'"
        @params  = Event::MessageParser.parse2(@message)
      end
      
      should "return array containing tag names" do
        assert_contains @params[:tags], "billable stuff" 
      end
    end
    
    context "given message containing duration" do
      context "in hh:mm:ss format" do
        setup do
          @message = "Working on a thing 2:00:00"
          @params  = Event::MessageParser.parse2(@message)
        end

        should "extract duration" do
          assert_not_nil @params[:duration]
        end

        should "return correct time in hours" do
          assert_equal 2.hours, @params[:duration]
        end
      end
      
      context "in hh:mm format" do
        setup do
          @message = "Working on a thing 1:30"
          @params  = Event::MessageParser.parse2(@message)
        end

        should "extract duration" do
          assert_not_nil @params[:duration]
        end

        should "return correct time in hours" do
          assert_equal 1.5.hours, @params[:duration]
        end
      end
    end
  
    context "given message containing date" do
      context "in MM/DD/YYYY format" do
        setup do
           @message = "@Hello world 3/19/2009"
           @params  = Event::MessageParser.parse2(@message)
        end
        
        should "return date" do
          assert_equal "3/19/2009".to_date, @params[:date]
        end
      end
      
      context "in M/D/YY format" do
        setup do
           @message = "@Hello world 12/3/08"
           @params  = Event::MessageParser.parse2(@message)
        end
        
        should "return date" do
          assert_equal "2008-12-03".to_date, @params[:date]
        end
      end
    end
  
    context "given message containing offset" do
      setup do
        @message = "Started working on the awesomeness [-2:15]"
        @params  = Event::MessageParser.parse2(@message)
      end
      
      should "return offset param" do
        assert_equal Time.utc(2008,2,15,9,45,0), @params[:start]
      end
    end
    
    context "given message containing start time in brackets" do
      context "in 24-hour format" do
        setup do
          Time.zone = 'Central Time (US & Canada)'
          @message = "Started working on the awesomeness [16:15]"
          @params  = Event::MessageParser.parse2(@message)
        end

        teardown do
          Time.zone = 'UTC'
        end

        should "return offset param" do
          assert_equal Time.zone.local(2008,2,15,16,15,0), @params[:start]
        end
      end
      
      context "in 12-hour format" do
        setup do
          Time.zone = 'Central Time (US & Canada)'
          @message = "Started working on the awesomeness [6:15 pm]"
          @params  = Event::MessageParser.parse2(@message)
        end

        teardown do
          Time.zone = 'UTC'
        end

        should "return offset param" do
          assert_equal Time.zone.local(2008,2,15,18,15,0), @params[:start]
        end
      end
    end
  end
  
  
end