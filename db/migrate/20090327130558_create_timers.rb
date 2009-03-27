class CreateTimers < ActiveRecord::Migration
  def self.up
    create_table :timers do |t|
      t.belongs_to :account, :user, :subject, :created_by
      t.integer    "status", :default => 0
      t.text       "body"
      t.datetime   "start"
      t.datetime   "stop"
      t.datetime   "state_changed_at"
      t.timestamps
    end
  end

  def self.down
    drop_table :timers
  end
end
