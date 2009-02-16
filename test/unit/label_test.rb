require 'test_helper'

class LabelTest < ActiveSupport::TestCase
  
  context "A new Label instance" do
    should_belong_to :account
    should_validate_presence_of :name, :account
    should_allow_values_for :name, "billable", "Name of client"
  end
  
end
