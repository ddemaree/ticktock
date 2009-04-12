class Ticktock  
  cattr_accessor :beta
  @@beta = true
  
  class Fuckup < Exception; end
  class Confrused < Exception; end
  
  class << self
  
    def account
      @@current_account ||= nil
    end
    
    def account=(acct)
      raise ArgumentError, "Must be an Account, was #{acct.class.to_s}" unless acct.is_a?(Account)
      @@current_account = acct
    end
    
    def user
      @@current_user ||= nil
    end
    
    def user=(u)
      raise ArgumentError, "Must be a User" unless u.is_a?(User)
      @@current_user = u
      UserAssignmentObserver.current_user = u
    end
    
    def reset!
      @@current_user = nil
      @@current_account = nil
    end
  
    def beta?
      !!@@beta
    end
    
    def handle_message(message)
      raise Fuckup, "Must set Ticktock.account and Ticktock.user before using the message handler" if (!account || !user)
      raise Fuckup, "Message can't be blank" if message.blank?
      
      params = Event::MessageParser.parse2(message)
      send(params[:action], params)
    end
    
    def start(params)
      event = account.events.build
      event.set_attributes_from_message(params)
      event.save!
      event
    end
    
    def stop(params)
      event = Ticktock.user.events.current
      return if event.nil?
      event.sleep!
      event
    end
    
    def current(params)
      event = Ticktock.user.events.current
    end
    alias_method :status, :current
    
    def method_missing(method_name,*args,&block)
      [method_name, args]
    end
  
  end
end

def Ticktock(msg)
  return Ticktock.handle_message(msg)
end