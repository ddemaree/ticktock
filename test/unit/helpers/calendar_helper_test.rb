require 'test_helper'

class CalendarHelperTest < ActionView::TestCase
  
  context "duration_in_words" do
    should "handle times in minutes" do
      assert_equal "3 minutes", duration_in_words(3.minutes)
    end
    
    should "display minutes when over an hour" do
      assert_equal "1 hour 30 minutes", duration_in_words(1.5.hours)
    end
    
    should "only show hours if no minutes" do
      assert_equal "2 hours", duration_in_words(2.hours)
    end
  end
  
  context "duration_in_billable_hours" do
    should "round to nearest 15m" do
      assert_equal 5.75, duration_in_billable_hours(5.70.hours)
    end
  end
  
  context "tag_class" do
    should "return tag1 for durations of 1hr or less" do
      time = 59.minutes
      assert_equal 'tag1', tag_class(time)
    end
    
    should "return tag2 for durations of 1-3 hrs" do
      time = 2.6.hours
      assert_equal 'tag2', tag_class(time)
    end
  end
  
end
