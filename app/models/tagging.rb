class Tagging < ActiveRecord::Base
  
  belongs_to :label
  belongs_to :event
  
end
