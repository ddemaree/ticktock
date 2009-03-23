require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @user    = Factory(:user)
    @account = @user.account
    @events  ||= []
  
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end
  
  context "GET to :index" do
    setup do
      create_events_tagged_with "alpha", :num => 5
      create_events_tagged_with "alpha", "beta", :num => 5
      
      get :index
    end
    
    should_respond_with :success
    should_render_template :index
    should_render_a_form
    should_assign_to :recents, :top_tags, :top_projects
    
  end

protected

  def create_events_tagged_with(*tagnames)
    
    options = (tagnames.last.is_a?(Hash) ? tagnames.pop : {})
    num = (options.delete(:num) || 2)
    
    tag_string = tagnames.collect { |t| "##{t}"  }.join(" ")
    
    params = options.reverse_merge!({
      :account => @account, :start=> nil, :stop => nil, :duration => 2.hours
    })
    
    num.times do |x|
      @events << Factory(:event, params.merge(:body => "#{Faker::Lorem.sentence} #{tag_string}", :date => (Date.today - x.days)))
    end
    
  end

end
