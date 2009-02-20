class Tagging < ActiveRecord::Base
  
  belongs_to :label
  belongs_to :event
  
protected

  def after_destroy
    self.label.destroy if self.label.taggings.count == 0
  end
  
end
