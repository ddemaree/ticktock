Factory.define :trackable do |t|
  t.association :account
  t.name { Faker::Company.name }
  t.nickname { |t| "#{t.name.gsub(/[^A-Za-z\-_]/,"")}"  }
end

Factory.define :label do |l|
  l.association :account
  l.name { Faker::Lorem.word }
end

Factory.define :tagging do |l|
  l.association :event
  l.account { |l| l.event.account }
end