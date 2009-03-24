class AddStateColumnToTrackables < ActiveRecord::Migration
  def self.up
    add_column :trackables, :state, :string, :default => 'active'
    add_index :trackables, :state
  end

  def self.down
    remove_index :trackables, :state
    remove_column :trackables, :state
  end
end
