require 'test_helper'

class EventTest < ActiveSupport::TestCase
  
  def setup
    Date.stubs(:today).returns Date.new(2008,2,15)
    Time.stubs(:now).returns Time.utc(2008,2,15,12,0,0)
  end
  
  should_have_named_scope :active
  
  context "Event import token generator" do
    should "generate signature from date and body" do
      today = Date.new(2009,2,15)
      expected_signature = "Hello world:2009-02-15:::"
      assert_equal expected_signature, Event.signature("Hello world", today)
    end
    
    should "generate token from date and body" do
      expected_digest = "b03a7a3ddd2d4529995f6cf5ff8ea4d6a3a24b4e"
    end
  end
  
  context "A new Event instance" do
    should_belong_to :account
    should_belong_to :user, :created_by
    should_have_one  :timer
    should_validate_presence_of :body, :account
    
    should "require stop to be later than start" do
      event = Factory.build(:timed_event, :stop => "1997-08-24 00:02:33")
      assert !event.valid?
      assert event.errors.on(:stop)
    end

    should "auto populate date to today" do
      event = Factory.build(:event, :start => nil, :stop => nil, :date => nil)
      assert event.valid?
      assert_equal Date.today, event.date
    end

    should "auto populate date from start if blank" do
      event = Factory.build(:timed_event, :date => nil)
      assert event.valid?
      assert_equal event.start.to_date, event.date
    end

    should "populate duration from start and stop" do
      event = Factory(:timed_event)
      assert_not_nil event.duration
      assert_equal 3.hours, event.duration
    end
    
    should "have #kind set to event" do
      event = Factory(:event)
      assert_equal "event", event.kind
    end
    
    should "provide import signature" do
      event = Event.new({
        :body => "Hello world",
        :date => Date.today
      })
      
      assert_not_nil event.signature
      assert_equal "Hello world:2008-02-15:::", event.signature
    end
    
    should "set import token" do
      event = Factory(:timed_event, :body => "Hello world")
      assert_equal "1bcaf55e80d0c3cd58a3c8c02571ecea78a9d9ea", event.import_token
    end
    
  end
  
  context "Event message parser" do
    setup do
      @account = Factory(:account)
      @user    = Factory(:user, :account => @account)
    end
    
    should "allow setting of tags" do
      message = "Hello world #tag1 #tag2"
      event   = @account.events.create(:body => message)
      assert_not_nil event.tags
      
      assert_equal message, event.body
      assert_equal 2, event.tags.length
    end
    
    should "allow setting of duration" do
      message = "Hello world 1:45"
      event   = @account.events.create(:body => message)
      assert_not_nil event.duration
      assert_not_nil 1.75.hours, event.duration
    end
    
    should "take duration from body when duration is provided separately" do
      message = "Hello world 1:45"
      event   = @account.events.create(:duration => "", :body => message)
      
      assert_not_nil event.duration
      assert_not_nil 1.75.hours, event.duration
    end
    
    should "allow setting of date" do
      message = "Hello world 12/3/1980"
      event   = @account.events.create(:body => message)
      assert_not_nil event.date
      assert_not_nil "1980-12-03".to_date, event.date
    end
    
    should "set date from body when provided separately" do
      message = "Hello world 12/3/1980"
      event   = @account.events.create(:date => "2009-01-01", :body => message)
      assert_not_nil event.date
      assert_not_nil "1980-12-03".to_date, event.date
    end
  end
  
  
  context "Event subject" do
    setup do
      Ticktock.account = @account = accounts(:test_account)
      Ticktock.user    = @user    = users(:quentin)
      
      @event = Factory.build(:event, :user => nil)
    end
    
    should "be settable via text" do
      @event.subject = "Yoga"
      assert_not_nil @event.subject
      assert @event.subject.is_a?(Trackable)
    end
    
    should "be settable via attribute in combo with body" do
      @event = Factory.build(:event, :subject => "Yoga", :account => @account)
      assert_not_nil @event.subject
    end
  end
  
  context "Event user" do
    setup do
      @account = accounts(:test_account)
      @user    = users(:quentin)
      @event   = Factory.build(:event, :user => nil, :account => @account)
    end
    
    should "be settable via username" do
      @event.user = "quentin"
      assert_not_nil @event.user
      assert_equal   @user, @event.user
      assert_equal   @user.name, @event.user_name
    end
    
    should "require user to be from same account" do
      @event.user = "caddy" 
      assert_nil     @event.user
      assert_not_nil @event.user_name
      assert_equal   "caddy", @event.user_name
    end
  end
  
  context "Event duration" do
    setup do
      @event = Factory.build(:event, :date => "2009-01-20")
    end
    
    should "be settable via string" do
      @event.duration = "2 hours"
      assert_equal (3600 * 2), @event.duration
    end
  end
  
  
  
  context "Event.find_and_extend" do
    setup do
      @account = Factory(:account)
      @events  = []
      @tags    = %w(alpha beta gamma beta alpha)
      
      4.times do |x|
        @events << Factory(:event, :account => @account, :duration => 5.hours, :body => "Blah blah ##{@tags[x]}")
      end
      
      @events << Factory(:event, :account => @account, :duration => 5.hours, :date => (Date.today - 2.weeks))
    end
    
    should "return 5 events" do
      assert_equal 5, @account.events.count
    end
    
    should "return EventSet#total_duration" do
      assert_not_nil @seconds = @account.events.find_and_extend.total_duration
      assert_equal   25.hours, @seconds
    end
    
    should "return EventSet#count" do
      assert_equal 5, @account.events.find_and_extend.count
    end
    
    should "return EventSet#tags" do
      assert_not_nil tags = @account.events.find_and_extend.tags
      assert_equal   3, tags.length, tags.inspect
    end
    
    should "work in combination with scopes" do
      range = (Date.today.beginning_of_week..Date.today.end_of_week)
      assert_nothing_raised do
        @ranged_events = @account.events.for_date_range(range).find_and_extend
      end
      
      assert_equal 4, @ranged_events.count
    end
  end
  
  context "Event quickbody" do
    
    context "with tags" do
      setup do
        @event = Factory(:event, :body => "03/19/2009 The quick brown #fox")
        @event.body = "03/19/2009 The #quick brown #fox"
        @event.save
      end
      
      should "have 2 tags" do
        assert_equal 2, @event.tags.length
        assert_equal 2, @event.taggings.count
      end      
    end
    
    context "with project" do
      setup do
        @subject = Factory(:trackable, :nickname => "fhqwhgads")
        @account = @subject.account
        @event = Factory(:event, :account => @account,
                                 :subject => @subject,
                                 :duration => 2.hours,
                                 :body => "@fhqwhgads 2:00 Awesomeness")
      end
      
      should "have a subject" do
        assert_not_nil @event.subject, @event.parsed_params.inspect
      end
    
      should "include subject" do
        assert_match /^(?:@fhqwhgads) /, @event.quick_body
      end
      
      should "include date" do
        assert_match /(?:02\/15\/2008)/, @event.quick_body
      end
      
      should "include duration" do
        assert_match /(?:2:00)/, @event.quick_body
      end
      
      should "preserve attributes if re-saved from quickbody" do
        @old_event = @event.dup
        assert @event.update_attributes(:body => @event.quick_body)
        assert_equal @old_event.date, @event.date
        assert_equal @old_event.duration, @event.duration
        assert_equal @old_event.subject, @event.subject
        assert_equal @old_event.body, @event.body
      end
      
      should "update attributes from quickbody" do
        @old_event = @event.dup
        @event.quick_body = @event.quick_body.gsub(/(?:02\/15\/2008)/, "03/19/2009")
        assert @event.save
        assert_equal "03/19/2009".to_date, @event.date
        assert_equal @old_event.body, @event.body
      end
    end
    
  end
  
end
