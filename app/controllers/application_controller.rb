# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  
  include AuthenticatedSystem
  include HoptoadNotifier::Catcher
  
  layout 'default'

  before_filter :adjust_format_for_mobile
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
  
  def self.section_name(name)
    before_filter do |controller|
      controller.instance_eval do
        @section_name = name
      end
    end
  end
  
  def current_events_path(options={})
    url_for((session[:events_view]||={}).merge(options))
  end
  
  def current_events_path_for(event)
    view_mode = (session[:events_view][:controller] || "calendar")
    
    if view_mode == "calendar"
      current_events_path({
        :week => @event.date.cweek,
        :year => @event.date.year
      })
    else
      current_events_path
    end
  end
  helper_method :current_events_path, :current_events_path_for
  
  def redirect_to_param_or_default(default=root_path)
    redirect_to(params[:return] || params[:return_to] || default)
  end
  
  def current_timer
    @current_timer ||= current_account.timers.current
  end
  helper_method :current_timer
  
  def event_params
    params[:tagged] ||= (params[:tag] || params[:tags])
    @event_params ||= Event::Params.new(params)
  end
  helper_method :event_params
  
  def current_project
    @current_project = current_account.trackables.find_by_id(event_params[:project]) ||
                       current_account.trackables.find_by_nickname(event_params[:project]) ||
                       current_account.trackables.find_by_name(event_params[:project])
  end
  helper_method :current_project

protected

  # TODO: Add support for other mobile browsers
  def adjust_format_for_mobile    
    if request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(iPhone|iPod)/]
      request.format = :mobile
    end
  end
  
  def account_host(account_or_subdomain="www")
    subdomain =
      case account_or_subdomain
        when String  then account_or_subdomain
        when Account then account_or_subdomain.domain
      end
    
    "#{subdomain}.#{base_domain}"
  end
  
  def base_domain
    output = []
    output += request.subdomains[1..10]
    output << "#{request.domain}#{request.port_string}"
    output.join(".")
  end
  helper_method :base_domain
  
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
    if current_subdomain.nil?
      redirect_to :host => default_host and return false
    end
    
    @current_account = Account.find_by_domain!(current_subdomain)
    Ticktock.account = @current_account
    
    Time.zone = @current_account.timezone
  rescue ActiveRecord::RecordNotFound => @e
    render "#{RAILS_ROOT}/public/404.html", :status => 404
  end
  
  def set_current_user
    return unless logged_in?
    Ticktock.user = current_user
    
    session[:events_view] = {
      :controller => 'calendar'
    }
  end
  
end
