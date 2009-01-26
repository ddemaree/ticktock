ActionController::Routing::Routes.draw do |map|
  
  map.with_options :controller => 'events' do |events|
    events.resources :events
    events.start     '/start', :action => 'start', 
                        :conditions => {:method => :post}                        
    events.stop      '/stop',  :action => 'stop', 
                        :conditions => {:method => :post}
    
    #events.start '/start', :action => 'start', :conditions => {:method => :post}
  end
  
  map.resources :trackables, :events
  map.resource :session, :account
  map.signup '/signup', :controller => 'accounts', :action => 'new'

  # map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  # map.login '/login', :controller => 'sessions', :action => 'new'
  # map.register '/register', :controller => 'users', :action => 'create'
  # map.signup '/signup', :controller => 'users', :action => 'new'
  # map.resources :users
  
  
  
  map.root :controller => 'website'

end
