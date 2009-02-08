require 'test_helper'

class Event::TaggableTest < ActiveSupport::TestCase
  
  context "A new Event instance" do
    setup { @event = Factory.build(:event) }
    
    should "accept tags passed as string" do
      @event.tags = "one, two"
      assert_equal "[one] [two]", @event.tag
    end
    
    should "return empty array for tags" do
      assert_equal [], @event.tags
    end

    should "return array once tags are set" do
      @event.tags = "one, two"
      assert_contains @event.tags, "two"
    end
    
    should "create tags after save" do
      assert_difference "@event.taggings.count" do
        @event.tags = "one"
        assert @event.save
      end
    end
    
    should "create labels in same account as self" do
      @event.tags = "mytag"
      @event.save
      assert_not_nil @event.labels.first
      assert_equal @event.account, @event.labels.first.account
    end
  end
  
  context "Cached label serializer" do
  
    should "convert cached tags to array" do
      cached_string = "[hello] [world] [never more]"
      tags_array = Label.unserialize(cached_string)
      assert_equal 3, tags_array.length
      assert_contains tags_array, "never more"
    end
    
    should "convert array to cached tags" do
      tags_array = %w(one two three four)
      cached_string = Label.serialize(tags_array)
      assert_equal "[one] [two] [three] [four]", cached_string
    end
  
  end
  
end