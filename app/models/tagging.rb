class Tagging < ActiveRecord::Base
  
  belongs_to :label, :counter_cache => true
  belongs_to :event
  
protected

  def before_save
    self.date     = self.event.date
    self.duration = self.event.duration
  end

  def after_destroy
    self.label.destroy if self.label.taggings.count == 0
  end
  
end
