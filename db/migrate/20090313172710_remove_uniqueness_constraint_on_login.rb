class RemoveUniquenessConstraintOnLogin < ActiveRecord::Migration
  def self.up
    remove_index :users, :column => :login
  end

  def self.down
    add_index :users, :login, :unique => true
  end
end
