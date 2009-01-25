class CreateTrackables < ActiveRecord::Migration
  def self.up
    create_table :trackables do |t|
      t.integer :account_id
      t.string :name
      t.string :nickname

      t.timestamps
    end
  end

  def self.down
    drop_table :trackables
  end
end
