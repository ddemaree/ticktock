module Event::Taggable
  
  def self.included(base)
    base.class_eval do
      has_many :taggings
      has_many :labels, :through => :taggings
      
      after_save :update_tags
      
      named_scope :tagged_with, lambda { |tags|
        tags = Label.parse(tags)
        conditions = tags.inject([]) do |coll, tag_name|
          coll << "tag LIKE '%[#{tag_name}]%'"; coll
        end
        {:conditions => conditions.join(" AND ")}
      }
    end
  end
  
  def tags=(list)
    @tags_as_array = Label.parse(list)
    self.tag = Label.serialize(@tags_as_array)
    @tags_as_array
  end
  
  def tags
    @tags_as_array ||= Label.unserialize(self.tag.to_s)
  end
  
  def update_tags
    Label.transaction do
      taggings.destroy_all
      
      self.tags.each do |tag|
        self.labels << self.account.labels.find_or_create_by_name(tag)
      end
      
      @tags_as_array = nil
    end
  end
  
end