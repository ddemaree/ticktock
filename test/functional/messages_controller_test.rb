require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  
  # #   R O U T I N G   # #
  should_route :post, "/messages", :action => :create
  should_route :post, "/emails",   :action => :create_from_email
  
  context "POST to :create" do
    context "with default after action" do
      setup {
        setup_session
        post :create, :message => "Hello world"
      }

      should_respond_with :redirect
      should_redirect_to("welcome screen") { root_path }
      should_assign_to :result
    end
    
    context "with return param" do
      setup {
        setup_session
        post :create, :message => "Hello world", :return => "/calendar"
      }
      
      should_respond_with :redirect
      should_redirect_to("specified URI") { "/calendar" }
    end
  end
  
  context "POST to :create_from_email" do
    context "with valid message" do
      setup {
        post :create_from_email, :email => email_message
      }

      should_assign_to :message
      should_respond_with 201

      should "be acceptable" do
        assert assigns(:message).acceptable?, assigns(:message).errors.full_messages
      end
    end
    
    context "with bad message" do
      setup {
        post :create_from_email, :email => email_message(:invalid)
      }
      
      should_respond_with 422
    end
    
    context "with lots of linebreaks" do
      setup {
        post :create_from_email, :email => email_message(:linebreaks)
      }
      
      should_assign_to :message
      should_respond_with 201
    end
  end
  
protected

  def email_message(name=:valid)
    File.read("#{RAILS_ROOT}/test/fixtures/emails/#{name.to_s}.txt")
  end

  def setup_session
    @account   = accounts(:test_account)
    @user      = @account.users.first
    @trackable = @account.trackables.first
    
    # All requests are at account domain with logged-in user unless
    # otherwise specified in the test method
    @request.host    = "#{@account.domain}.ticktockapp.com"
    @request.session = {:user_id => @user.id}
  end

  def bad_email_message
    email_message(:invalid)
  end
  
end
