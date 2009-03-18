Gem::Specification.new do |s|
  s.name    = 'practical_form_helpers'
  s.version = '0.1.0'
  s.date    = '2009-02-09'
  s.summary = %{Useful extensions to ActionView's form helpers}
  
  s.authors = ["David Demaree"]
  s.email   = 'david@practical.cc'
  s.homepage = 'http://github.com/ddemaree/practical_form_helpers'
  
  s.has_rdoc = false
  
  s.files = %w(README.rdoc MIT-LICENSE init.rb lib/practical_form_helpers.rb lib/practical/labeled_form_builder.rb test/practical_form_helpers_test.rb test/test_helper.rb)
  s.test_files = %w(test/practical_form_helpers_test.rb test/test_helper.rb)
end