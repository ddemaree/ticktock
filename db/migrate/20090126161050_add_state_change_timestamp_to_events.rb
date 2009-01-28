class AddStateChangeTimestampToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :state_changed_at, :datetime
  end

  def self.down
    remove_column :events, :state_changed_at
  end
end
