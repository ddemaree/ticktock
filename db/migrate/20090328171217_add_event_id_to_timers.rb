class AddEventIdToTimers < ActiveRecord::Migration
  def self.up
    add_column :timers, :event_id, :integer
  end

  def self.down
    remove_column :timers, :event_id
  end
end
