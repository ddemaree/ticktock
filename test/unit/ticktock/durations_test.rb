require 'test_helper'

class Ticktock::DurationsTest < ActiveSupport::TestCase
  
  context "time_to_units" do
    should "handle hours" do
      hours, minutes, seconds = Ticktock::Durations.time_to_units(1.5.hours)
      assert_equal 1, hours
      assert_equal 30, minutes
    end
  end
  
  context "duration_to_string" do
    
    should "return default format with zero suppression" do
      formatted_string = Ticktock::Durations.duration_to_string(2.hours)
      assert_equal "2h", formatted_string
    end
    
    should "return default format for hours and minutes" do
      formatted_string = Ticktock::Durations.duration_to_string(2.5.hours)
      assert_equal "2h 30m", formatted_string
    end
    
    should "allow format override" do
      formatted_string = Ticktock::Durations.duration_to_string(2.5.hours, "%H hours %M minutes")
      assert_equal "2 hours 30 minutes", formatted_string
    end
    
    should "allow format override with optionals" do
      formatted_string = Ticktock::Durations.duration_to_string(2.hours, "%H hours {%M minutes}")
      assert_equal "2 hours", formatted_string
    end
    
    should "return billables on request" do
      formatted_string = Ticktock::Durations.duration_to_string(1.75.hours, "%B hours")
      assert_equal "1.75 hours", formatted_string
    end
    
    should "return zero-padded minutes" do
      formatted_string = Ticktock::Durations.duration_to_string(1.75.hours, "%H:%N")
      assert_equal "1:45", formatted_string
    end
    
    should "return zero-padded minutes for hours with no minutes" do
      formatted_string = Ticktock::Durations.duration_to_string(1.hours, "%H:%N")
      assert_equal "1:00", formatted_string
    end
    
    should "return zero-padded minutes for minutes with no hours" do
      formatted_string = Ticktock::Durations.duration_to_string(42.minutes, "%H:%N")
      assert_equal "0:42", formatted_string
    end
    
  end
  
  context "duration_in_billable_hours" do
    should "round to nearest 15m" do
      assert_equal 5.75, Ticktock::Durations.duration_in_billable_hours(5.70.hours)
    end
  end
  
end