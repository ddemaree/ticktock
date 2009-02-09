namespace :ticktock do
  
  desc "Generates fake data for David to play with"
  task :fake_data => :environment do
    Account.destroy_all :conditions => "domain != 'practical'"
    
    ENV["ACCOUNT"] ||= "practical"
    account = Account.find_by_domain(ENV["ACCOUNT"]) ||
              Factory(:account, :domain => ENV["ACCOUNT"])
    
    60.times do
      Factory(:event, :account => account)
    end
  end
  
end