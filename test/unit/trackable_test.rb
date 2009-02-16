require 'test_helper'

class TrackableTest < ActiveSupport::TestCase
  
  should_belong_to :account
  should_validate_uniqueness_of :nickname, :scoped_to => :account_id
  should_validate_presence_of :name
  should_not_allow_values_for :nickname, "My Nickname", "Hey there!!!", "You know..."
  
end
