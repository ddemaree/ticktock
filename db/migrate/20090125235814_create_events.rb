class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      
      t.belongs_to :account, :null => false
      t.references :subject, :polymorphic => true
      t.belongs_to :user
      
      t.string   :state
      t.string   :kind
      t.text     :body
      t.datetime :start
      t.datetime :stop
      t.date     :date
      t.integer  :duration
      
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
  
end
