class AddImportTokenToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :import_token, :string
    add_column :events, :imported_id, :datetime
    add_index :events, :import_token
  end

  def self.down
    remove_index :events, :import_token
    remove_column :events, :imported_id
    remove_column :events, :import_token
  end
end
