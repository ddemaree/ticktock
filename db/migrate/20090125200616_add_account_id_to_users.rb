class AddAccountIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :account_id, :integer
    add_index :users, [:login, :account_id], :unique => true
  end

  def self.down
    remove_index :users, :column => [:login, :account_id]
    remove_column :users, :account_id
  end
end
