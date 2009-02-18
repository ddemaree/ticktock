set :application, "ticktock"
#set :repository,  "git://"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, "deploy"
set :deploy_to, "/var/www/apps/#{application}"

role :app, "practical.cc"
role :web, "practical.cc"
role :db,  "practical.cc", :primary => true

namespace :deploy do
  
  task :setup_environment do
    transaction do
      update_code
      symlink
      
      sudo "cd #{current_path} && rake gems:install RAILS_ENV=#{environment}"
    end
  end
  after "deploy:setup", "deploy:setup_environment"
  
end