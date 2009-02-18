set :application, "ticktock"
#set :repository,  "git://"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, "practical"
set :deploy_to, "/var/www/apps/#{application}"

default_run_options[:pty] = true
set :scm, "git"
set :repository, "git@github.com:ddemaree/ticktock.git"
set :scm_passphrase, "tt_red5BULL"
set :branch, "master"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

role :app, "practical.cc"
role :web, "practical.cc"
role :db,  "practical.cc", :primary => true

namespace :deploy do
  
  task :setup_environment do
    transaction do
      update_code
      symlink
      
      rails_env = fetch(:rails_env, "production")
      run "cd #{current_path} && #{try_sudo} rake gems:install RAILS_ENV=#{rails_env}"
    end
  end
  after "deploy:setup", "deploy:setup_environment"
  
  task :restart do
    run "cd #{current_path} && touch tmp/restart.txt"
  end
  
  task :restart_apache do
    sudo "/usr/local/apache2/bin/apachectl restart"
  end
  
end