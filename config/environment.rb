# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  # config.action_controller.session = {
  #   :session_key => '_com_ticktockapp_session',
  #   :secret      => 'bc25e97d55eb997a950f8fa780870044'
  # }

  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com', :version => '~> 2.2.3'

  config.gem 'rubyist-aasm', :lib => 'aasm', :source => 'http://gems.github.com', :version => '~> 2.0.2'
  
  config.gem 'gchart', :version => '~>0.5.0'
  
  config.gem 'fastercsv', :version => '~>1.2.3'
  
  config.gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com', :version => '~>2.2.6'
 
  config.gem 'sprockets', :version => '~>1.0.2'
  
  #config.gem 'fiveruns-dash-rails', :lib => "fiveruns_dash_rails", :source => 'http://gems.github.com'
  
  config.active_record.observers = :user_assignment_observer
  config.time_zone = 'UTC'
 
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end