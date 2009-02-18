require 'test_helper'

class Event::MessageParserTest < ActiveSupport::TestCase
  
  def self.should_preserve_message
    should "preserve message content" do
      assert_equal "Hello world", @params[:body]
    end
    
    should "retain original message source" do
      assert_equal @message, @params[:source]
    end
  end
  
  context "Messages containing tags" do
    setup do
      @message = "Hello world #taggable #shizzle #shizzle"
      @params  = Event::MessageParser.parse(:body => @message)
    end
    
    should_preserve_message
    
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
  
end