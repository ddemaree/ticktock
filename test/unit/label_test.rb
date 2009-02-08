require 'test_helper'

class LabelTest < ActiveSupport::TestCase
  
  context "A new Label instance" do
    should_belong_to :account
    should_require_attributes :name, :account
    #should_not_allow_values_for :name, "f:k"
    should_allow_values_for :name, "billable", "Name of client"
  end
  
end
