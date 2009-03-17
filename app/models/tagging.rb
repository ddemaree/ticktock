class Tagging < ActiveRecord::Base
  
  belongs_to :label
  belongs_to :event
  
  after_save :update_tag_stats
  
protected

  def update_tag_stats
    self.label.update_stats!
  end

  def before_save
    self.date     = self.event.date
    self.duration = self.event.duration.to_i
  end

  def after_destroy
    self.label.destroy if self.label.taggings.count == 0
  end
  
end
