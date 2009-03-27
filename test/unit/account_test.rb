require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  
  should_validate_uniqueness_of :domain
  should_validate_presence_of :domain
  should_ensure_length_in_range :domain, 3..24
  
  should_have_many :users
  should_have_many :trackables
  should_have_many :timers
  should_have_one  :account_owner
  
  def setup
    Ticktock.beta = false
  end
  
  def teardown
    Ticktock.beta = false
  end
  
  context "A new Account instance" do
    setup { @account = Factory.build(:account)}
    
    context "while in beta" do
      setup { Ticktock.beta = true }
      should_validate_presence_of :invite_code
    end
    
    should "exclude reserved domains" do
      @account.domain = 'www'
      
      assert !@account.valid?
      assert @account.errors.on(:domain)

      @account.domain = "anything_but_www"
      assert @account.valid?, @account.errors.full_messages
    end

    should "generate API key on save" do
      @account.save!
      assert_not_nil @account.api_key
    end
  end
  
end
