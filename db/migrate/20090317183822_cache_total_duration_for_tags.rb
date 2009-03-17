class CacheTotalDurationForTags < ActiveRecord::Migration
  def self.up
    add_column :labels, :total_duration, :integer
    
    Tagging.reset_column_information
    Tagging.find_each do |tagging|
      say "Updating duration #{tagging.event.duration} on tagging #{tagging.inspect}"
      tagging.update_attributes!({
        :date     => tagging.event.date,
        :duration => tagging.event.duration.to_i
      })
    end
    
    Label.reset_column_information
    Label.find_each(:batch_size => 50) { |t|
      t.update_stats!
      say "Updating tag #{t.inspect}"
    }
  end

  def self.down
    remove_column :labels, :total_duration
  end
end
