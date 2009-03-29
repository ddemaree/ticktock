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
  
  
  
  # def setup
  #   @params = {
  #     :tagged     => ["hello", "world"]
  #     :date_after => "2009-03-01"
  #   }
  # end
  
  def test_parse_for_modifiers
    flunk "Whoa, dude what are you doing here?"
  end
  
end