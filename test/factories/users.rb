Factory.define :account do |a|
  a.sequence(:domain) { |x| "test#{x}"  }
  a.name     "Test Account"
  a.timezone "Central Time (US & Canada)"
end

Factory.sequence :login do |n|
  "user#{n}"
end

Factory.define :user do |u|
  u.association :account
  u.name  { Faker::Name.name }
  u.login { Factory.next(:login) }
  u.password { "blahblah" }
  u.password_confirmation { |u| u.password }
  u.email { Faker::Internet.email }
end