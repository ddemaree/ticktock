class EventsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  rescue_from ActiveRecord::RecordInvalid, :with => :respond_on_invalid_event
  
  def index
    session[:events_view] = {
      :controller => 'events',
      :page => params[:page],
      :per_page => params[:per_page],
      :tags => params[:tags],
      :trackable_id => params[:trackable_id]
    }
    
    scoped_events = current_account.events.filtered({
      :trackable => params[:trackable_id],
      :tag => params[:tags]
    })
    
    @events = scoped_events.paginate(:all, :per_page => (params[:per_page] || 20), :page => params[:page])
    
    respond_to do |format|
      format.html
      format.csv  {
        send_data generate_csv(@events), :content_type => Mime::CSV, :filename => "#{current_subdomain}_ticktockapp_com-events-#{Time.zone.now.to_i}.csv"
      }
      format.xml  { render :xml  => @events }
      format.json { render :json => @events }
    end
  end
  
  def new
    @section_name = "new_event"
    @event = current_account.events.build
    
    respond_to do |format|
      format.html
      format.quick
      format.xml  { render :xml  => @event }
      format.json { render :json => @event }
    end
  end
  
  def add_multiple
    @section_name = "new_event"
    @event = current_account.events.build
  end
  
  def create
    if params[:event].keys.any? { |k| !!((k.to_s =~ /^\d+$/) == 0)  }
      return create_several_via_hash
    elsif params[:events] && params[:events].is_a?(Array)
      raise "Array format"
    end
    
    # Single event in hash format is default
    @event = current_account.events.build
    @event.update_attributes! params[:event]
    
    # TODO: Better flash copy here
    # FIXME: current_events_path can't seem to set root as current
    respond_to do |format|
      format.html { 
        redirect_to_param_or_default
      }
      format.js   {
        headers["X-JSON"] = @event.to_json
        render :partial => 'list_item', :locals => {:event => @event }, :status => :created
      }
      format.xml  { render :xml  => @event, :status => :created, :location => @event }
      format.json { render :json => @event, :status => :created, :location => @event }
    end
  
  rescue ActiveRecord::RecordInvalid
    respond_on_failed_create @event
    
  end
  
  def create_several_via_hash
    @events = []
    @unsaved_events = []
    
    params[:event].each do |key, params|
      next if params[:body].blank?
      
      event = current_account.events.build
      event.attributes = params
      
      if event.save
        @events << event 
      else
        @unsaved_events << event
      end
    end
    
    flash[:notice] = "Created #{@events.length} event#{"s" if @events.length != 1}"
    redirect_to(params[:return] == "yes" ? request.referrer : root_path)
  end
  
  def edit
    @event = current_account.events.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js {
        headers["X-JSON"] = @event.to_json
        render :text => @event.quick_body
      }
    end
  end
  
  def show
    @event = current_account.events.find(params[:id])
    respond_to do |format|
      format.json { render :json => @event.to_json }
      format.xml  { render :xml  => @event.to_xml  }
    end
  end
  
  def update
    @event = current_account.events.find(params[:id])
    @event.update_attributes!(params[:event])
    
    respond_to do |format|
      format.html { redirect_to_param_or_default @event.permalink }
      format.xml  { head :ok }
      format.json { head :ok }
      format.js {
        headers["X-JSON"] = @event.to_json
        render :partial => 'list_item', :locals => {:event => @event}
      }
    end

  rescue ActiveRecord::RecordInvalid
    respond_on_failed_create @event
  end
  
  def destroy
    @event = current_account.events.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(current_events_path) }
      format.xml  { head :ok }
      format.atom { head :ok }
    end
  end
  
protected
  
  def respond_on_invalid_event
    respond_to do |format|
      format.html { redirect_to events_path and return }

      format.xml  { render :xml => @event.errors,  :status => :unprocessable_entity, :location => @event }

      format.json  { render :json => @event.errors,  :status => :unprocessable_entity, :location => @event }
    end
  end
  
  def respond_on_failed_create(object=@event)
    respond_to do |format|
      format.html { render :action => (object.new_record? ? "new" : "edit") }
      format.xml  { render :xml  =>  object.errors, :status => :unprocessable_entity }
      format.json { render :json =>  object.errors, :status => :unprocessable_entity }
    end
  end
  
  def generate_csv(events)
    csv_string = FasterCSV.generate do |csv|
      events.each do |event|
        csv << [
          event.id,
          event.date.to_s(:db),
          event.start, #.try(:to_s(:db),
          event.stop, #.to_s(:db),
          event.subject.try(:nickname),
          event.body,
          event.duration,
          event.hours
        ]
      end
    end
  end

end
