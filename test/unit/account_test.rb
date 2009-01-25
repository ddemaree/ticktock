require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  
  should_require_unique_attributes :domain
  should_require_attributes :name, :domain, :timezone
  should_ensure_length_in_range :domain, 3..24
  
  should "exclude reserved domains" do
    new_account = Factory.build(:account, :domain => "www")
    
    assert !new_account.valid?
    assert new_account.errors.on(:domain)
    
    new_account.domain = "anything_but_www"
    assert new_account.valid?, new_account.errors.full_messages
  end
  
end
