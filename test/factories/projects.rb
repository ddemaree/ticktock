Factory.define :trackable do |t|
  t.account  { (Ticktock.account ||= Factory(:account)) }
  t.name     { Faker::Company.name }
  t.nickname { |t| "#{t.name.gsub(/[^A-Za-z\-_]/,"")}"  }
end