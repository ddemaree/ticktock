class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.string :domain
      t.string :timezone
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
