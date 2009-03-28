Factory.define :timer do |timer|
  timer.association :account
  timer.body "Working on a thing"
  timer.start { Time.now - 2.hours }  
end

# create_table "punches", :force => true do |t|
#   t.integer  "timer_id"
#   t.string   "from_state"
#   t.string   "to_state"
#   t.integer  "duration"
#   t.datetime "start"
#   t.datetime "stop"
#   t.datetime "created_at"
#   t.datetime "updated_at"
# end

Factory.define :punch do |p|
  p.association :timer
  p.from_state  0
  p.to_state    1
  p.duration    7200
  p.start       { Time.now - 2.hours }
  p.stop        { Time.now }
end

# Factory.define :paused_timer, :parent => :timer do |t|
#   t.status           1
#   t.state_changed_at { Time.now }
#   
#   #t.punches          { [t.association :punch] }
#   t.punches do |p|
#     [p.association(:punch, :timer => t)]
#   end
# end