class UserAssignmentObserver < ActiveRecord::Observer
  
  cattr_accessor :current_user
  observe Event
  
  # def before_validation(model)
  #   return unless current_user
  #   model.user =  current_user
  # end
  
  def before_create(model)
    return unless current_user
    return unless model.respond_to?(:created_by=)
    model.created_by ||= current_user
  end
  
  def before_save(model)
    return unless current_user
    return unless model.respond_to?(:user=)
    model.user ||= current_user
  end
  
  def current_user
    @@current_user
  end
  
end
