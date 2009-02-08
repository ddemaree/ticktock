class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table :labels do |t|
      t.integer :account_id
      t.string :name
      t.integer :taggings_count

      t.timestamps
    end
  end

  def self.down
    drop_table :labels
  end
end
