class ChangePunchesToTimers < ActiveRecord::Migration
  def self.up
    Punch.delete_all
    rename_column :punches, :event_id, :timer_id
  end

  def self.down
    Punch.delete_all
    rename_column :punches, :timer_id, :event_id
  end
end
