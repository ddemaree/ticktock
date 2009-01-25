ActionController::Routing::Routes.draw do |map|
  
  map.resources :trackables
  map.resource :session, :account
  map.signup '/signup', :controller => 'accounts', :action => 'new'

  # map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  # map.login '/login', :controller => 'sessions', :action => 'new'
  # map.register '/register', :controller => 'users', :action => 'create'
  # map.signup '/signup', :controller => 'users', :action => 'new'
  # map.resources :users
  
  
  
  map.root :controller => 'website'

end
