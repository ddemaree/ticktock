class Test::Unit::TestCase
  
  def self.should_set_current_user_on(assign)
    should "assign #{assign} to current user" do
      assert_not_nil assigns(:current_user), "The action isn't setting @current_user"
      assert_not_nil assigns(assign.to_sym).user, "The action isn't setting @#{assign}.user"
      assert_equal   assigns(:current_user), assigns(assign).user
    end
  end
  
end