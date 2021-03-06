ActionController::Routing::Routes.draw do |map|
  SprocketsApplication.routes(map) 
  
  map.reports '/reports', :controller => 'reports'
  map.report  '/reports/:action', :controller => 'reports'
  
  map.resources :messages, :only => [:create]
  map.emails    '/emails', :controller => 'messages', :action => 'create_from_email',
                           :conditions => {:method => :post}
  
  map.resources :event_imports, :member => {:mapping => :get}, :except => [:index, :show, :edit]
  
  map.resources :users
  
  map.resources :trackables, :has_many => [:events, :duplicates]
  
  map.with_options :controller => 'calendar', :action => 'index' do |calendar|
    
    calendar.calendar       '/calendar'
    calendar.calendar_year  '/calendar/:year', :year => /\d{4}/
    calendar.calendar_week  '/calendar/:year/w/:week', :year => /\d{4}/, :week => /\d+/
    calendar.calendar_month '/calendar/:year/:month', :year => /\d{4}/, :month => /\d+/
    calendar.calendar_day   '/calendar/:year/:month/:day', :year => /\d{4}/, :month => /\d+/, :day => /\d+/
  end
  
  map.with_options :controller => 'timers' do |timers|
    timers.resources :timers, :member => {
            :sleep => :post, :wake => :post, :finish => :post}
    
    # timers.start '/start', :action => 'start', 
    #                 :conditions => {:method => :post}                        
    # timers.stop  '/stop',  :action => 'stop', 
    #                 :conditions => {:method => :post}             
    # timers.stop  '/pause', :action => 'pause', 
    #                 :conditions => {:method => :post}
  end
  
  map.with_options :controller => 'events' do |events|
    events.resources :events
    events.connect '/:year/w/:week/events', :action => 'index'
    events.connect '/:year/w/:week/events.:format', :action => 'index'
  end
  
  map.namespace :account do |account|
    map.resource :theme
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
