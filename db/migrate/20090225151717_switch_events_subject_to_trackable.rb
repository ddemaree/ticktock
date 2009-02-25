class SwitchEventsSubjectToTrackable < ActiveRecord::Migration
  def self.up
    remove_column :events, :subject_type
  end

  def self.down
    add_column :events, :subject_type, :string
  end
end
