require 'test_helper'

class Event::FilteringTest < ActiveSupport::TestCase
  
  def setup
    @account = Factory(:account)
    @subject = Factory(:trackable, :account => @account)
    @events = []
    
    2.times { @events << Factory(:event, :account => @account, :subject => @subject) }
    
    3.times do |x|
      @events << Factory(:event, :account => @account, :tags => %w(alpha beta gaga))
    end
  end
  
  should "filter by :tagged_with" do
    tagged_events = Event.filtered(:tagged_with => "alpha")
    assert_equal 3, tagged_events.length 
  end
  
  should "filter by :trackable" do
    tagged_events = Event.filtered(:trackable => @subject)
    assert_equal 2, tagged_events.length 
  end
  
  should "filter by searchlogic conditions" do
    filtered = Event.filtered(:created_at_gte => Date.today.beginning_of_year)
    assert_equal 6, filtered.count
  end
  
  should "filter in combination with tag" do
    tagged_events = Event.filtered({:tag => "alpha", :created_at_gte => Date.today.beginning_of_year})
    assert_equal 3, tagged_events.count
  end
  
  should "filter in combination with subject" do
    tagged_events = Event.filtered({:trackable => @subject, :created_at_gte => Date.today.beginning_of_year})
    assert_equal 2, tagged_events.count
  end
  
end