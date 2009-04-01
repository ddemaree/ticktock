class Ticktock  
  cattr_accessor :beta
  @@beta = true
  
  class Fuckup < Exception; end
  
  class << self
  
    def account
      @@current_account ||= false
    end
    
    def account=(acct)
      raise ArgumentError, "Must be an Account, was #{acct.class.to_s}" unless acct.is_a?(Account)
      @@current_account = acct
    end
    
    def user
      @@current_user ||= false
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
      
      params = Event::MessageParser.parse(:body => message)
      send(params[:action], params)
    end
    
    def create(params)
      event = account.events.build
      
      event.attributes = {
        :body => params[:body],
        :subject => params[:subject],
        :date => params[:date],
        :duration => params[:duration]
      }
      event.save!
      event
    end
    
    # Stubs for creating and working with Timers
    # def start(params)
    #   raise "Not implemented"
    # end
    # 
    # def stop(params)
    #   raise "Not implemented"
    # end
    # 
    # def pause(params)
    #   raise "Not implemented"
    # end
    
    def method_missing(method_name,*args,&block)
      [method_name, args]
    end
  
  end
end

def Ticktock(msg)
  return Ticktock.handle_message(msg)
end