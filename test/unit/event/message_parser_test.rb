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
  
  context "Messages containing action" do
    setup do
      @message = "start @GWOD Something #neat 0:15"
      @params  = Event::MessageParser.parse(:body => @message)
    end
    
    should "extract action" do
      assert_equal "start", @params[:action]
    end
    
    should "preserve message" do
      assert_equal "Something #neat", @params[:body]
    end
    
    should "extract duration" do
      assert_equal 15.minutes, @params[:duration]
    end
  end
  
  context "Messages containing tags" do
    setup do
      @message = "Hello world #taggable #shizzle #shizzle"
      @params  = Event::MessageParser.parse(:body => @message)
    end
    
    should "preserve message content with tags" do
      assert_equal @message, @params[:body]
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
        @message = "Hello world @Practical"
        @params  = Event::MessageParser.parse(:body => @message)
      end
      
      should_preserve_message
      should_preserve_message_source

      should "extract trackable" do
        assert_equal "Practical", @params[:subject]
      end
    end
    
    context "using [] syntax" do
      setup do
        @message = "[Practical] Hello world"
        @params  = Event::MessageParser.parse(:body => @message)
      end
      
      should_preserve_message

      should "extract trackable" do
        assert_equal "Practical", @params[:subject]
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
    
    context "in 1.75h format" do
      setup do
        @message = "Working on a thing 1.75h"
        @params  = Event::MessageParser.parse(:body => @message)
      end
      
      should "extract duration" do
        assert_not_nil @params[:duration]
      end
      
      should "return correct time in hours" do
        assert_equal 1.75.hours, @params[:duration]
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
      
      context "in MM-DD-YYYY format" do
        setup do
          @message = "12-3-1980 was born"
          @params  = Event::MessageParser.parse(:body => @message)
        end
        
        should "extract date" do
          #flunk @params.inspect
          assert_not_nil @params[:date]
          assert_equal "1980-12-03".to_date, @params[:date]
        end
      end
    end

    # TODO: Hook up this parser
    # context "in 1h 25m format" do
    #   setup do
    #     @message = "Working on a thing 1h 25m"
    #     @params  = Event::MessageParser.parse(:body => @message)
    #   end
    #   
    #   should "extract duration" do
    #     assert_not_nil @params[:duration]
    #   end
    #   
    #   should "return correct time in hours" do
    #     assert_equal((1.hours + 25.minutes), @params[:duration])
    #   end
    # end
    
  end
  
end