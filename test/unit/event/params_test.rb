require 'test_helper'

# class Event::Params
#   
#   class Modifier
#     cattr_accessor :modifiers
#     @@modifiers = []
#     
#     attr_reader :name, :aliases
#     
#     def initialize(name,*aliases)
#       @name = name
#       @aliases = aliases
#       
#       self.class.modifiers << self
#     end
#   
#   end
#   
# end

class Event::ParamsTest < ActiveSupport::TestCase
  
  # supported params:
  # tagged, not_tagged
  # date, date_before, date_after
  # duration, duration_gte, duration_lte, duration_lt, duration_gt
  # is:starred, not:starred
  # has:project, no:project
  # has:tags, no:tags
  # has:duration, no:duration
  # project:, not_project:
  # body_includes, body_excludes
  
  # modifiers: has, no, is, not, before|lt, after|gt, on_or_before|lte, on_or_after|gte
  
  # fields: tagged, date, duration, starred, project, body
  # modifiers: (is), not|is_not, includes, excludes, before|lt, after|gt, on_or_before|lte, on_or_after|gte, has, does_not_have
  
  def test_handle_gt
    # Should compile to 'duration > 3600'
    #operators = %w(has is not before less_than after greater_than on_or_before lte on_or_after gte)
    
    params = {
      :duration_from => "1 hour",
      :duration_to => 7200,
      :date_before  => "yesterday",
      :tagged => "blah",
      :not_tagged => "yada",
      :keywords => "blah blah",
      :not_keywords => "blah yada",
      :project => "",
      :created_before => "1 hour ago",
      :starred => true
    }
    
    o_params = Event::Params.new(params)
    
    flunk o_params.conditions.inspect
  end
  
end