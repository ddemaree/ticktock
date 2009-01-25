require 'faker'

Factory.sequence :domain do |n|
  "test#{n}"
end

Factory.define :account do |a|
  a.name     "Test Account"
  a.domain   { Factory.next(:domain) }
  a.timezone "Central Time (US & Canada)"
end

Factory.define :trackable do |t|
  t.association :account
  t.name { Faker::Company.name }
  t.nickname { |t| "#{t.name.gsub(/[^A-Za-z\-_]/,"")}"  }
end