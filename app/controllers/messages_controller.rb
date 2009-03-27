class MessagesController < ApplicationController
  
  def create
    @result = Ticktock(params[:message])
    
    respond_to do |format|
      format.html { redirect_to(params[:return] || root_path) }
      format.json { render :json => @result.to_json, :status => :created, :location => @result }
      format.xml  { render :xml  => @result.to_xml, :status => :created, :location => @result}
    end
  rescue Ticktock::Fuckup => @e
    respond_to do |format|
      format.html {
        flash[:notice] = "Couldn't handle that message, dude"
        redirect_to(params[:return] || root_path)
      }
      format.xml  { head :unprocessable_entity }
      format.json { head :unprocessable_entity }
    end
  end
  
  def create_from_email
    @message = Email.parse(params[:email])
    logger.info(@message.inspect)
    
    if @message.acceptable?
      @message.accept!
      
      respond_to do |format|
        format.xml  { head :created }
        format.json { head :created }
      end
    else
      @message.reject!
      
      respond_to do |format|
        format.xml  { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
    
  end
  
end
