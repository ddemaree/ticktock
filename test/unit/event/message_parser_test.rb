require 'test_helper'

class Event::MessageParserTest < ActiveSupport::TestCase
  
  def self.should_preserve_message
    should "preserve message content" do
      assert_equal "Hello world", @params[:body]
    end
  end
  
  def self.should_preserve_message_source
    should "retain original message source" do
      assert_equal @message, @params[:source]
    end
  end
  
  context "Ragel based message parser" do
    
    setup do
      @message = "@GWOD Something #neat 0:15"
      @params  = Event::MessageParser.parse(@message)
    end
    
    should "have indifferent access" do
      assert_not_nil @params[:body]
      assert_not_nil @params["body"]
      assert_equal @params[:body], @params["body"]
    end
    
  end
  
  context "Messages containing tags" do
    setup do
      @message = "Hello world #taggable #shizzle #shizzle"
      @params  = Event::MessageParser.parse(:body => @message)
    end
    
    should "preserve message content with tags" do
      assert_equal @message, @params[:body], @params.inspect
    end
    
    should_preserve_message_source
     
    should "extract tags" do
      assert_not_nil @params[:tags]
      assert_equal 3, @params[:tags].length, @params[:tags].inspect
      assert_contains @params[:tags], 'taggable'
    end
  end
    
  context "Messages containing trackable" do
    context "using @ syntax" do
      setup do
        @message = "@practical Hello world"
        @params  = Event::MessageParser.parse(@message)
      end
      
      should_preserve_message
      should_preserve_message_source

      should "extract trackable" do
        assert_equal "practical", @params[:subject]
      end
    end
  end

  context "Messages containing duration" do
    context "in hh:mm:ss format" do
      setup do
        @message = "Working on a thing 2:00:00"
        @params  = Event::MessageParser.parse(:body => @message)
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
        @message = "Working on a thing 2:00"
        @params  = Event::MessageParser.parse(:body => @message)
      end

      should "extract duration" do
        assert_not_nil @params[:duration]
      end

      should "return correct time in hours" do
        assert_equal 2.hours, @params[:duration]
      end
    end
  end

  context "Messages containing date" do
    context "in MM/DD/YYYY format" do
      setup do
        @message = "12/3/1980 was born"
        @params  = Event::MessageParser.parse(:body => @message)
      end
      
      should "extract date" do
        #flunk @params.inspect
        assert_not_nil @params[:date]
        assert_equal "1980-12-03".to_date, @params[:date]
      end
      
      context "as well as duration" do
        setup do
          @message = "12/3/1980 was born 0:05"
          @params  = Event::MessageParser.parse(:body => @message)
        end
        
        should "extract date" do
          assert_not_nil @params[:date]
          assert_equal "1980-12-03".to_date, @params[:date]
        end
        
        should "extract duration" do
          assert_not_nil @params[:duration]
        end
        
        should "provide correct duration" do
          assert_equal 5.minutes, @params[:duration]
        end
      end
    end
  end
  
  context "Messages containing several parameters" do
    setup do
      @message = "@CaptainU 04/01/2009 0:20 #Call with Avi"
      @params  = Event::MessageParser.parse(:body => @message)
    end
    
    should "strip date components from message" do
      assert_equal "#Call with Avi", @params[:body]
    end
    
    should "return date" do
      assert_equal "2009-04-01".to_date, @params[:date]
    end
    
    should "return duration" do
      assert_equal 20.minutes, @params[:duration]
    end
    
    should "return project" do
      assert_equal "CaptainU", @params[:subject]
    end
    
  end
  
end