class Capistrano::Configuration

  ##
  # Print an informative message with asterisks.

  def inform(message)
    puts "#{'*' * (message.length + 4)}"
    puts "* #{message} *"
    puts "#{'*' * (message.length + 4)}"
  end

  ##
  # Read a file and evaluate it as an ERB template.
  # Path is relative to this file's directory.

  def render_erb_template(filename)
    template = File.read(filename)
    result   = ERB.new(template).result(binding)
  end

  ##
  # Run a command and return the result as a string.
  #
  # TODO May not work properly on multiple servers.
  
  def run_and_return(cmd)
    output = []
    run cmd do |ch, st, data|
      output << data
    end
    return output.to_s
  end

end

namespace :web do
  desc "Restarts Apache"
  task :restart_apache, :role => :web do
    sudo "/usr/local/apache2/bin/apachectl restart"
  end
end

namespace :practical do
  
  namespace :config do
    
    desc "Create shared/config directory and default database.yml."
    task :setup do
      run "mkdir -p #{shared_path}/config"

      # Copy database.yml if it doesn't exist.
      result = run_and_return "ls #{shared_path}/config"
      unless result.match(/database\.yml/)
        contents = render_erb_template(File.dirname(__FILE__) + "/templates/database.yml")
        put contents, "#{shared_path}/config/database.yml"
        inform "Please edit database.yml in the shared directory."
      end
    end
    #after "deploy:setup", "practical:config:setup"

    desc "Copy config files"
    task :copy do
      run "cp #{shared_path}/config/* #{release_path}/config/"
    end
    
    desc "Symlink config files"
    task :symlink do
      run "ln -s #{shared_path}/config/* #{release_path}/config/"
    end
    after "deploy:update_code", "practical:config:symlink"
  
  end
  
end