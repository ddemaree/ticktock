module Event::Taggable
  
  def self.included(base)
    base.send(:extend,  ClassMethods)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      has_many :taggings, :dependent => :destroy
      has_many :labels, :through => :taggings
      
      after_save :update_tags
      
      named_scope :tagged_with, lambda { |tags|
        {:conditions => Event.conditions_for_tags(tags)}
      }
    end
  end
  
  module ClassMethods
    
    def conditions_for_tags(tags, all=true)
      tags = Label.parse(tags)
      
      conditions = tags.inject([]) do |coll, tag_name|
        coll << "tag LIKE '%[#{tag_name}]%'"; coll
      end
      
      #{}"(#{conditions.join(" #{all ? 'AND' : 'OR'} ")})"
    
      {:tag_contains => (tags.collect { |t| "[#{t}]" }) }
    end
    
    
    
  end
  
  module InstanceMethods
    def tags=(list)
      @tags_as_array = Label.parse(list)
      self.tag = Label.serialize(@tags_as_array)
      @tags_as_array
    end

    def tags
      @tags_as_array ||= Label.unserialize(self.tag.to_s)
    end
    
    def tag_string
      self.tags.join(", ")
    end
    
    def tag_string=(string)
      self.tags = string
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
  
end