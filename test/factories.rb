require 'faker'

Factory.sequence :domain do |n|
  "test#{n}"
end

Factory.sequence :login do |n|
  "user#{n}"
end

Factory.define :account do |a|
  a.name     "Test Account"
  a.domain   { Factory.next(:domain) }
  a.timezone "Central Time (US & Canada)"
end

Factory.define :user do |u|
  u.association :account
  u.name  { Faker::Name.name }
  u.login { Factory.next(:login) }
  u.password { "blahblah" }
  u.password_confirmation { |u| u.password }
  u.email { Faker::Internet.email }
end

Factory.define :trackable do |t|
  t.association :account
  t.name { Faker::Company.name }
  t.nickname { |t| "#{t.name.gsub(/[^A-Za-z\-_]/,"")}"  }
end

Factory.define :event do |e|
  e.association :account
  e.association :subject, :factory => :trackable
  e.body  { Faker::Lorem.sentence }
  e.date  "2009-01-23"
  e.start { "2009-01-23 00:02:33".to_time }
  e.stop  { |e| e.start + 3.hours }
end