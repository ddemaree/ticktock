module Ticktock::Subjects
  
  def self.included(base)
    base.class_eval do
      
      belongs_to :subject, :class_name => "Trackable"
      alias_method :subject_from_object=, :subject=
      attr_reader :subject_changed
      
      def subject=(object_or_name)
        return nil unless (self.account ||= (Ticktock.account || nil))
        
        @subject_changed = true
        logger.debug("Setting subject_changed to true")
        
        if object_or_name.is_a?(String)
          if obj = self.account.trackables.find_by_name(object_or_name) ||
                   self.account.trackables.find_by_nickname(object_or_name)

            self.subject_from_object = obj
          else
            self.subject_from_object = self.account.trackables.build(:nickname => object_or_name)
          end
        else
          self.subject_from_object = object_or_name
        end
      end
      
      # Reset subject_changed
      def after_save
        @subject_changed = nil
      end
      
    end
  end
  
end