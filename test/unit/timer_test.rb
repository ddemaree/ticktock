require 'test_helper'

class TimerTest < ActiveSupport::TestCase
  
  should_belong_to :account
  should_belong_to :user
  should_belong_to :subject
  should_belong_to :created_by
  
  context "a new Timer instance" do
    setup { @timer = Factory.build(:timer) }
  
    should "have aasm_state" do
      assert_equal "active", @timer.aasm_state
    end
    
    should "respond to aasm state query method" do
      assert @timer.active?
    end
  
    should "set numeric state from aasm_state" do
      @timer.aasm_state = "completed"
      assert_equal 2, @timer.status
    end
    
    should "set initial start time" do
      @timer.save
      assert_not_nil @timer.start
    end
    
  end
  
end
