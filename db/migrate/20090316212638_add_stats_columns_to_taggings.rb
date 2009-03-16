class AddStatsColumnsToTaggings < ActiveRecord::Migration
  def self.up
    change_table(:taggings) do |t|
      t.integer :duration
      t.date    :date
    end
    
    Tagging.each(:include => :event) do |tagging|
      tagging.update_attributes!({
        :date     => tagging.event.date,
        :duration => tagging.event.duration
      })
    end
  end

  def self.down
    change_table(:taggings) do |t|
      t.remove :duration, :date
    end
  end
end
