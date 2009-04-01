class Email < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  #belongs_to :event
  
  validates_presence_of :to, :from, :body, :message_source
  
  attr_reader :mail
  def self.parse(raw)
    @mail = Email::Message.parse(raw)
    
    # TODO: Need to add seekrit validation
    if @current_account = Account.find_by_domain(@mail.subdomain)
      @current_user    = @current_account.users.find_by_email(@mail.parsed_sender.address)
    end
    
    new({
      :message_source => raw,
      :body     => @mail.body,
      :to       => @mail.parsed_recipient.address,
      :from     => @mail.parsed_sender.address,
      :account  => @current_account,
      :user     => @current_user
    })
  end
  
  def accept!
    Event.transaction do
      self.update_attributes!(:accepted => true)
      
      # Set system account/user and pass it to the message handler
      Ticktock.account = account
      Ticktock.user    = user
      Ticktock(self.body)
    end
  end
  
  def message_body
    self.body
  end
  
  def reject!
    self.update_attributes!(:accepted => false)
  end
  
  def acceptable?
    (valid? && !account.nil? && !user.nil?)
  end
  
  def to_event
    @event = self.account.events.build(:user => self.user)
    @event.attributes = self.to_event_params
    @event
  end
  
  def to_event!
    self.to_event.save!
  end
  
  def to_event_params
    @event_params ||= Event::MessageParser.parse(:body => body)
  end
  
end