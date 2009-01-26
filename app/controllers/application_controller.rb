# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include AuthenticatedSystem

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :set_current_account
  before_filter :login_required
  before_filter :set_current_user
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html {
        render :file => "#{Rails.root}/public/404.html", :status => 404
      }
      format.json { head 404 }
      format.xml  { head 404 }
    end
  end
  
  # def self.api_key_allowed_for(*allowed_actions)
  #   # def authorized
  #   #       logged_in? or logged_in_via_api_key?
  #   #     end
  #   
  #   class_eval do
  #     def authorized
  #       if allowed_actions.include?(action_name)
  #       super or logged_in_via_api_key?
  #     end
  #   end
  # end

protected
  
  def account_host(account_or_subdomain="www")
    subdomain =
      case account_or_subdomain
        when String  then account_or_subdomain
        when Account then account_or_subdomain.domain
      end
    
    "#{subdomain}.#{request.domain}#{request.port_string}"
  end
  
  def current_account
    @current_account ||= Account.find_by_domain!(current_subdomain)
  end
  helper_method :current_account
  
  def current_subdomain
    request.subdomains.first
  end
  
  def default_host
    account_host("www")
  end
  
  def logged_in_via_account_api_key?
    !!(current_account && params[:api_key] && (params[:api_key] == current_account.api_key))
  end
  
  def set_current_account
    @current_account = Account.find_by_domain!(current_subdomain)
  rescue ActiveRecord::RecordNotFound => @e
    render "#{RAILS_ROOT}/public/404.html", :status => 404
  end
  
  def set_current_user
    return unless logged_in?
    UserAssignmentObserver.current_user = current_user
  end
  
end
