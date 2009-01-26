class AddUserNameToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :user_name, :string
  end

  def self.down
    remove_column :events, :user_name
  end
end
