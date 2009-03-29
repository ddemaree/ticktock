require 'test_helper'

class Event::FilteringTest < ActiveSupport::TestCase
  
  def setup
    #@account ||= Factory(:account)
    #@subject ||= Factory(:trackable, :account => @account)
    Ticktock.account = @account = accounts(:test_account)
    @subject = trackables(:self_trackable)
    
    @events = []
    
    2.times do |x|
      @events << @account.events.create({
        :body    => Faker::Lorem.sentence,
        :subject => @subject,
        :starred => (x == 0)
      })
    end
    
    3.times do |x|
      @events << Factory(:event, :account => @account, :body => %(Hi #alpha #beta #gaga))
    end
  end
  
  # Starred is a searchlogic condition, doesn't need special handling
  should "filter by :starred" do
    starred_events = Event.filtered(:starred => true)
    assert_equal 1, starred_events.length, Event.options_for_filter(:starred => true)
  end
  
  should "filter by :tagged_with" do
    tagged_events = Event.filtered(:tagged_with => "alpha")
    assert_equal 3, tagged_events.length 
  end
  
  should "filter by :trackable" do
    project_events = Event.filtered(:trackable => @subject)
    assert_equal @events.first.account, @account
    
    assert_equal 2, project_events.length, @events.inspect
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
    assert_equal 2, tagged_events.count, @subject.inspect
  end
  
end