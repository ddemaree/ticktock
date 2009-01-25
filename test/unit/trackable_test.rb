require 'test_helper'

class TrackableTest < ActiveSupport::TestCase
  
  should_belong_to :account
  should_require_unique_attributes :nickname, :scoped_to => :account_id
  should_require_attributes :name
  should_not_allow_values_for :nickname, "My Nickname", "Hey there!!!", "You know..."
  
end
