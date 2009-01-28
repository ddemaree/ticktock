set :application, "ticktock"
#set :repository,  "git://"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, "deploy"
set :deploy_to, "/var/www/#{application}"

role :app, "katsushiro.practical.cc"
role :web, "katsushiro.practical.cc"
role :db,  "katsushiro.practical.cc", :primary => true