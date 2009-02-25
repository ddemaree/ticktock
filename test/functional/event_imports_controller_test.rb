require 'test_helper'

class EventImportsControllerTest < ActionController::TestCase

  should_route :get,  "/events/import", :action => :new
  should_route :post, "/event_imports", :action => :create

  def setup
    @account   = Factory(:account)
    @user      = Factory(:user, :account => @account)
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end
  
  context "on GET to :new" do
    setup { get :new }
    
    should_respond_with :success
    should_render_template :new
    should_render_a_form
  end

  context "on POST to :create" do
    setup { post :create, {:uploaded_file => uploaded_file }}
    
    should_respond_with :success
    should_assign_to :imported_events
    
    should "have imported events count of 1" do
      assert_equal 1, assigns(:imported_events).length
    end
    
    should "set created_by on created events" do
      assert_equal @user, assigns(:imported_events).first.created_by
    end
  end

protected

  def uploaded_file
    @uploaded_file ||= ActionController::TestUploadedFile.new("#{RAILS_ROOT}/test/fixtures/imports/csv_data.txt", "text/plain", false)
  end

end
