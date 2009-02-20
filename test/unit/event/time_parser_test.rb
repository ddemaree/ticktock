require 'test_helper'

class Event::TimeParserTest < ActiveSupport::TestCase
  
  def self.should_return_seconds(seconds)
    should "return time in seconds" do
      assert_equal seconds, Event::TimeParser.from_string(@message)
    end
  end
  
  context "When converting string to time" do
    context "in hh:mm:ss format" do
      setup { @message = "1:30:29" }
      should_return_seconds(1.5.hours + 29.seconds)
    end
    
    context "in hh:mm format" do
      setup { @message = "1:30"}
      should_return_seconds(1.5.hours)
    end
    
    context "in 1.75h format" do
      setup { @message = "1.75h"}
      should_return_seconds(1.75.hours)
    end
    
    context "in 1h 25m 30s format" do
      setup { @message = "1h 25m 30s"}
      should_return_seconds(1.hour + 25.minutes + 30.seconds)
    end
  end
  
end