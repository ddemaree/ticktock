Factory.define :event_import do |import|
  import.association :account
  import.source { ActionController::TestUploadedFile.new("#{RAILS_ROOT}/test/fixtures/imports/csv_data.txt", "text/plain", false) }
end