require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  def setup
    @user = Factory(:user)
    @account = @user.account
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end

  context "GET to :top_tags" do
    setup do
      create_events_tagged_with("alpha", :num => 3)
      create_events_tagged_with("beta", :num => 5)
      create_events_tagged_with("gamma", :num => 2, :duration => 6.hours)
      create_events_tagged_with("delta", :num => 10, :duration => 0)
    end
    
    context "by frequency" do
      setup do
        get :top_tags
      end

      should_assign_to :tags

      should "return 4 distinct tags" do
        assert_equal 4, assigns(:tags).length
      end

      should "return most-used tag first" do
        assert_equal "delta", assigns(:tags).first.name
      end
    end
    
    context "by duration" do
      setup do
        get :top_tags, :by => "duration"
      end

      should_assign_to :tags

      should "return only tags with nonzero duration" do
        assert_equal 3, assigns(:tags).length
      end

      should "return most-used tag first" do
        assert_equal "gamma", assigns(:tags).first.name
      end
    end
  
  end
  
protected

  def create_events_tagged_with(*tagnames)
    #num = (tagnames.last.is_a?(Fixnum) ? tagnames.pop : 2)
    options = (tagnames.last.is_a?(Hash) ? tagnames.pop : {})
    num = (options.delete(:num) || 2)
    
    @account ||= Factory(:account)
    @events  ||= []
    
    tag_string = tagnames.collect { |t| "##{t}"  }.join(" ")
    
    params = options.reverse_merge!({
      :account => @account, :start=> nil, :stop => nil, :duration => 2.hours
    })
    
    num.times do |x|
      @events << Factory(:event, params.merge(:body => "#{Faker::Lorem.sentence} #{tag_string}", :date => (Date.today - x.days)))
    end
  end

end
