class Event::Importer
  attr_reader :account
  
  def initialize(account)
    raise ArgumentError, "Object passed to Event::Importer must be an Account" unless account.is_a?(Account)
    @account = account
    
  end
  
end