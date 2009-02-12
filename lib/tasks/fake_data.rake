namespace :ticktock do
  
  desc "Generates fake data for David to play with"
  task :fake_data => :environment do
    if defined?(Factory)
      Factory.define :dummy_event, :class => 'event' do |event|
        event.body { Faker::Company.bs }
        event.date { ((Date.today.beginning_of_week - 6.weeks)..Date.today.end_of_week).to_a.rand }
      end
    end
    
    
    Account.destroy_all :conditions => "domain != 'practical'"
    
    ENV["ACCOUNT"] ||= "practical"
    account = Account.find_by_domain(ENV["ACCOUNT"]) ||
              Factory(:account, :domain => ENV["ACCOUNT"])
    
    unless user = account.users.find_by_login("ddemaree")
      user = account.users.create!({
        :login => "ddemaree",
        :name  => "David Nemesis",
        :email => "david@practical.cc",
        :password => "kelsey",
        :password_confirmation => "kelsey"
      })
    end
    
    tags = %w(admin billable bugfix design testing)
    
    account.events.destroy_all
    
    60.times do
      #Factory(:event, :account => account)
      ev = Factory.build(:dummy_event, :account => account, :user => user)
      
      num_tags = rand(3)
      tags_for_this_event = []
      num_tags.times do |x|
        tags_for_this_event << tags.rand
      end
      
      ev.tags = tags_for_this_event
      
      #puts ev, ev.valid?
      ev.save!
    end
  end
  
end