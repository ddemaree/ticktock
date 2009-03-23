ActionController::Routing::Routes.draw do |map|
  SprocketsApplication.routes(map) 
  
  #map.connect '/emails.:format', :controller => 'emails', :action => 'create', :conditions => {:method => :post} 
  map.reports '/reports', :controller => 'reports'
  map.report  '/reports/:action', :controller => 'reports'
  
  map.resources :emails, :only => [:create]
  
  map.resources :event_imports, :member => {:mapping => :get}, :except => [:index, :show, :edit]
  
  map.connect '/events/add_multiple', :controller => 'events', :action => 'add_multiple'
  map.resources :events, :users
  
  map.resources :trackables, :has_many => [:events, :duplicates]
  
  map.with_options :controller => 'calendar', :action => 'index' do |calendar|
    
    calendar.calendar       '/calendar'
    calendar.calendar_year  '/calendar/:year', :year => /\d{4}/
    calendar.calendar_week  '/calendar/:year/w/:week', :year => /\d{4}/, :week => /\d+/
    calendar.calendar_month '/calendar/:year/:month', :year => /\d{4}/, :month => /\d+/
    calendar.calendar_day   '/calendar/:year/:month/:day', :year => /\d{4}/, :month => /\d+/, :day => /\d+/
  end
  
  
  map.with_options :controller => 'events' do |events|
    events.connect '/:year/w/:week/events', :action => 'index'
    events.connect '/:year/w/:week/events.:format', :action => 'index'
    
    events.start '/start', :action => 'start', 
                    :conditions => {:method => :post}                        
    events.stop  '/stop',  :action => 'stop', 
                    :conditions => {:method => :post}
  end
  
  map.resource :session, :account
  map.signup '/signup', :controller => 'accounts', :action => 'new'

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  # map.login '/login', :controller => 'sessions', :action => 'new'
  # map.register '/register', :controller => 'users', :action => 'create'
  # map.signup '/signup', :controller => 'users', :action => 'new'
  # map.resources :users
  
  map.root :controller => 'home'
end
