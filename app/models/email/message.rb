class Email::Message
  attr_reader :mail

  class << self
    attr_accessor :recipient_header_order
  end

  self.recipient_header_order = %w(original_to delivered_to to)

  def self.parse(raw)
    new TMail::Mail.parse(raw)
  end

  def initialize(email)
    @mail         = email
    @attachments  = []
  end

  def inspect
    "Email to #{seekrit} at #{subdomain}:\nFrom: #{sender}\nSubject: #{subject}\n #{body}"
  end

  def seekrit
    @seekrit ||= mailbox.gsub(/^(?:dropbox|log)-/,"")
  end

  def mailbox
    parsed_recipient.local
  end

  def domain
    parsed_recipient.domain
  end

  def subdomain
    domain.split(/\./).first
  end

  def parsed_recipient(order=nil)
    TMail::Address.parse(recipient(order))
  end
  
  def parsed_sender
    TMail::Address.parse(sender)
  end

  def recipient(order = nil)
    order = self.class.recipient_header_order if order.blank?
    order.each do |key|
      value = send("recipient_from_#{key}")
      return value unless value.blank?
    end
  end

  def recipient_from_to
    @recipient_from_to ||= @mail['to'].to_s
  end

  def recipient_from_delivered_to
    @recipient_from_delivered_to ||= begin
      delivered = @mail['Delivered-To']
      if delivered.respond_to?(:first)
        delivered.first.to_s
      else
        delivered.to_s
      end
    end
  end

  def recipient_from_original_to
    @recipient_from_original_to ||= @mail['X-Original-To'].to_s
  end

  def body
    @body ||= begin
      if @mail.multipart?
        @attachments.clear
        @body = []
        scan_parts(@mail)
        @body = @body.join("\n")
      else
        @mail.body
      end
    end
  end

  def sender
    @sender ||= TMail::Unquoter.unquote_and_convert_to(@mail['from'].to_s, "utf-8")
  end

  def subject
    @mail.subject
  end

  class Attachment
    def initialize(part)
      @part    = part
      @is_read = false
    end

    def content_type
      @part.content_type
    end

    def filename
      @filename ||= @part.type_param("name")
    end

    # For IO API compatibility when used with Rest-Client
    def close
    end

    alias path filename

    def read(value = nil)
      if read?
        nil
      else
        @is_read = true
        data
      end
    end

    def read?
      @is_read == true
    end

    def data
      @part.body
    end

    def attached?
      !filename.nil?
    end

    def inspect
      %(#<Email::Attachment filename=#{filename.inspect} content_type=#{content_type.inspect}>)
    end
  end

protected
  def scan_parts(message)
    message.parts.each do |part|
      if part.multipart?
        scan_parts(part)
      else
        if part.content_type == "text/plain"
          @body << part.body
        else
          att = Attachment.new(part)
          @attachments << att if att.attached?
        end
      end
    end
  end
  
end