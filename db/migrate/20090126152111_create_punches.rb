class CreatePunches < ActiveRecord::Migration
  def self.up
    create_table :punches do |t|
      t.belongs_to :event
      t.string     :from_state, :to_state
      t.integer    :duration
      t.datetime   :start, :stop
      t.timestamps
    end
  end

  def self.down
    drop_table :punches
  end
end
