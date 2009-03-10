require 'test_helper'

class EventImportsControllerTest < ActionController::TestCase

  should_route :get,  "/event_imports/new", :action => :new
  should_route :post, "/event_imports", :action => :create
  
  should_route :get,  "/event_imports/1/mapping", :action => :mapping, :id => 1
  should_route :put,  "/event_imports/1", :action => :update, :id => 1

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
    setup do
      post(:create, {:event_import => {:source => uploaded_file}})
    end
    
    should_assign_to :event_import
    should_respond_with 302
    
    # FIXME: Why no work??
    #should_redirect_to("the mapping form") { mapping_event_import_url(@event_import) }
  end
  
  context "on GET to :mapping" do
    setup do
      @event_import = Factory(:event_import, :account => @account)
      get(:mapping, {:id => @event_import.to_param})
    end
    
    should_assign_to :event_import
    should_respond_with :success
    should_render_a_form
  end
  
  context "on PUT to :update" do
    setup do
      @event_import = Factory(:event_import, :account => @account)
      put(:update, {
        :id      => @event_import.to_param,
        :mapping => ["","body","start","stop","","subject"],
        :event_import => {:ignore_first => "1"}
      })
    end
    
    should_assign_to :imported_rows
    should_respond_with 302
    #should_set_the_flash
  end

protected

  def uploaded_file
    @uploaded_file ||= ActionController::TestUploadedFile.new("#{RAILS_ROOT}/test/fixtures/imports/csv_data.txt", "text/plain", false)
  end

end
