class CreateEventImports < ActiveRecord::Migration
  def self.up
    create_table :event_imports do |t|
      t.belongs_to :account
      
      t.integer :rows_in_source, :rows_imported
      
      t.string :source_file_name, :source_content_type
      t.integer :source_file_size
      t.datetime :source_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :event_imports
  end
end
