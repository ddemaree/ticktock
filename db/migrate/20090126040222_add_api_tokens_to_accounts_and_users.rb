class AddApiTokensToAccountsAndUsers < ActiveRecord::Migration
  def self.up
    add_column :accounts, :api_key, :string
    add_column :users,    :api_key, :string
  end

  def self.down
    remove_column :users,    :api_key
    remove_column :accounts, :api_key
  end
end
