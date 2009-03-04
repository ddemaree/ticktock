Factory.define :event do |e|
  e.association :account
  e.association :subject, :factory => :trackable
  e.body  { Faker::Lorem.sentence }
  e.date  { Date.today }
end

Factory.define :timed_event, :parent => :event do |e|
  e.start { |e| Time.now - 6.hours }
  e.stop  { |e| e.start + 3.hours }
  e.date  { |e| e.start.to_date }
end