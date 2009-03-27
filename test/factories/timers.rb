Factory.define :timer do |timer|
  timer.association :account
  timer.body "Working on a thing"  
end