class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.belongs_to :account, :user
      t.string :from, :to, :subject, :body
      t.boolean :accepted, :default => false
      t.text :message_source
      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
