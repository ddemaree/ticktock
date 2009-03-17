class AddStatsColumnsToTaggings < ActiveRecord::Migration
  def self.up
    change_table(:taggings) do |t|
      t.integer :duration
      t.date    :date
    end
  end

  def self.down
    change_table(:taggings) do |t|
      t.remove :duration, :date
    end
  end
end
