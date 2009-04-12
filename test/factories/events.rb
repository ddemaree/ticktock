Factory.define :event do |e|
  #e.association :account
  e.account { (Ticktock.account ||= Factory(:account)) }
  e.user    { |e| (Ticktock.user ||= e.account.users.first || Factory(:user, :account => e.account))}
  e.body    { Faker::Lorem.sentence }
  e.date    { Date.today }
end

Factory.define :event_with_subject, :parent => :event do |e|
  e.association :subject, :factory => :trackable
end

Factory.define :timed_event, :parent => :event do |e|
  e.start { |e| Time.now - 6.hours }
  e.stop  { |e| e.start + 3.hours }
  e.date  { |e| e.start.to_date }
end

Factory.define :active_event, :parent => :event do |e|
  e.start { |e| Time.now - 1.5.hours }
  e.date  { |e| e.start.to_date }
end

Factory.define :sleeping_event, :parent => :event do |e|
  e.start            { |e| Time.now - 1.5.hours  }
  e.state_changed_at { |e| Time.now - 30.minutes }
  e.duration         1.hour
  e.state            'sleeping'
  e.date             { |e| e.start.to_date }
end