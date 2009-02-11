ActionController::Routing::Routes.draw do |map|
  
  map.resources :events, :trackables, :users
  
  
  
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

  # map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  # map.login '/login', :controller => 'sessions', :action => 'new'
  # map.register '/register', :controller => 'users', :action => 'create'
  # map.signup '/signup', :controller => 'users', :action => 'new'
  # map.resources :users
  
  map.root :controller => 'website'

end
