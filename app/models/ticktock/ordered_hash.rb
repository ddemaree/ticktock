class Ticktock::OrderedHash < ActiveSupport::OrderedHash
  
  def each_with_sorting
    @keys.sort.each {|key| yield [key, self[key]]}
  end
  alias_method_chain :each, :sorting
  
  def each_key_with_sorting
    @keys.sort.each { |key| yield key }
  end
  alias_method_chain :each_key, :sorting

  def each_value_with_sorting
    @keys.sort.each { |key| yield self[key]}
  end
  alias_method_chain :each_value, :sorting
  
  def keys_with_sorting
    @keys.dup.sort!
  end
  alias_method_chain :keys, :sorting
  
end