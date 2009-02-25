require 'test_helper'

class EventsHelperTest < ActionView::TestCase
  
  context "Link to tag" do
    setup { @output = link_to_tag("pork")}
    should "return link with tag attributes" do
      assert_dom_equal %{<a href="javascript:void%200" class="tag" title="Events tagged with pork" rel="tag">pork</a>}, @output
    end
  end
  
  context "Event message helper" do
    context "where message contains hashtags" do
      setup { @message = "Hello #world"; @output = event_message(@message)}

      should "convert hashtags to links" do
        assert_dom_equal %{Hello #{link_to_tag("world")}}, @output
      end
    end
  end
  
  context "event_subject" do
    context "where subject is Trackable" do
      setup { @trackable = Factory(:trackable); @output = event_subject(@trackable)}

      should "return wrapped link tag" do
        assert_dom_equal %{<strong class="trackable event_subject">#{link_to @trackable, @trackable}</strong>}, @output
      end
    end
  end
  
  # TODO: Do I just set up controller vars to test for this?
  context "span_for_user" do
  end
  
end
