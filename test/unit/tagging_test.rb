require 'test_helper'

class TaggingTest < ActiveSupport::TestCase

  context "When tagged event is created" do
    setup { 
      @event = Factory(:event, :body => "Hello #world #cool", :duration => 1.hour)
    }
    
    should "create taggings" do
      assert_equal 2, @event.taggings.count
    end
    
    should "copy event date to taggings" do
      assert_equal @event.date, @event.taggings.first.date
    end
    
    should "copy event duration to taggings" do
      assert_equal @event.duration, @event.taggings.first.duration
    end
    
    should "update total duration on tag" do
      tagging = @event.taggings.first
      tag     = tagging.label
      
      assert_equal tagging.duration, tag.total_duration
    end
  
  end
  
  context "When tagged event is updated" do
    setup do
      @event = Factory(:event, :body => "Hello #world #cool", :duration => 1.hour)
      @event.update_attributes!({
        :date => "2009-03-19".to_date,
        :duration => 2.hours
      })
    end
    
    should "update taggings with new date" do
      assert_equal @event.date, @event.taggings.first.date
    end
    
    should "update taggings with new duration" do
      tagging = @event.taggings.first
      assert_equal @event.duration, tagging.duration
      assert_equal 2.hours, tagging.duration
    end
    
    should "update tags with new total duration" do
      tagging = @event.taggings.first
      assert_equal 2.hours, tagging.label.total_duration
    end
  end

end
