require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  
  should_validate_uniqueness_of :domain
  should_validate_presence_of :domain
  should_ensure_length_in_range :domain, 3..24
  
  should "exclude reserved domains" do
    new_account = Factory.build(:account, :domain => "www")
    
    assert !new_account.valid?
    assert new_account.errors.on(:domain)
    
    new_account.domain = "anything_but_www"
    assert new_account.valid?, new_account.errors.full_messages
  end
  
  should "generate API key" do
    new_account = Factory(:account)
    assert_not_nil new_account.api_key
  end
  
  context "Account#events association" do
    should "respond to #import" do
      new_account = Factory(:account)
      assert new_account.events.respond_to?(:import)
    end
  end
  
end
