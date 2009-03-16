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
  
  end
  
  context "When tagged event is updated" do
    setup do
      @event = Factory(:event, :body => "Hello #world #cool", :duration => 1.hour)
      @event.update_attributes!({:date => "2009-03-19".to_date})
    end
    
    should "update taggings with new date" do
      assert_equal @event.date, @event.taggings.first.date
    end
    
    should "update taggings with new duration" do
      assert_equal @event.duration, @event.taggings.first.duration
    end
  end

end
