class AddStarredToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :starred, :boolean, :default => false
  end

  def self.down
    remove_column :events, :starred
  end
end
