class AddAccountOwnerColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :account_owner, :boolean, :default => false
    
    Account.find_each do |account|
      user = account.users.first
      user.account_owner = true
      user.save!
    end
    
  end

  def self.down
    remove_column :users, :account_owner
  end
  
end
