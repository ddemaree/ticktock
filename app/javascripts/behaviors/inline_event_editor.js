InlineEventEditor = Class.create({
	template: new Template('<form action="/events/#{eventId}" method="post"><input type="hidden" name="_method" value="put"><h4>Edit event (<a href="#">cancel</a>)</h4><p><textarea name="event[body]">#{quickBody}</textarea> <button type="submit">Save changes</button></p></form>'),
	initialize: function(link){
		this.link = link
		
		Object.extend(link, {
			inlineEditor: this
		})
		
		this.listItem = link.up('li')
		this.jsonUrl = this.link.href
		this.link.observe('click', this.onClick.bind(this))
	},
	getJSON: function(onComplete){
		new Ajax.Request(this.jsonUrl, {
			asynchronous:true,
			evalJSON:true,
			method:'get',
			onComplete:function(r,j){
				this.quickBody = r.responseText
				this.eventData = j.event
				onComplete()
			}.bind(this)
		})
	},
	onClick: function(e){
		if(!this.listItem.down('form')){
			this.getJSON(function(){
				this.setupForm()
			}.bind(this))
		}
		else {
			this.teardown()
		}
		e.stop()
	},
	setupForm: function(){
		Overlay.invoke({onClick:function(){
			this.teardown()
		}.bind(this)})
		
		this.listItem.insert({bottom:this})
		this.listItem.addClassName('editing')
		
		form = this.listItem.down('form')
		field = form.down('textarea')
		fieldHeight = Math.ceil($F(field).length / 36) * 22
		
		field.setStyle({
			width:Math.floor(this.listItem.getWidth() - 70) + 'px',
			height:fieldHeight+'px'
		})
		
		form.observe('submit', function(e){
			submitUrl = "/events/#{id}".interpolate({id:this.eventData.id})
			try {
				new Ajax.Request(submitUrl, {
					asynchronous:true,
					method:'put',
					evalJSON:true,
					parameters:Form.serialize(form),
					onSuccess:this.onSuccess.bind(this),
					onFailure:function(r,j){
						console.log("Update failed")
					}
				})
			}
			catch(err) {
				console.log(err)
			}
			e.stop()
		}.bind(this))
	},
	teardown: function(){
		this.listItem.down('form').remove()
		this.listItem.removeClassName('editing')
		Overlay.dismiss()
	},
	toElement: function(){
		formHtml = this.template.evaluate({
			eventId: this.eventData.id,
			quickBody: this.quickBody
		})
		return formHtml;
	},
	onSuccess: function(r,j){
		newObject = j.event
		if(!$(document.body).down('.events_for_day')){
			this.listItem.replace(r.responseText)
			this.setupNewEditor()
		}
		else if(newObject.date == this.eventData.date){
			this.listItem.replace(r.responseText)
			this.setupNewEditor()
		}
		else if((newObject.date != this.eventData.date)) {
			newDate = CalendarDate.parse(newObject.date)
			dateContainerId = "events_for_#{date}".interpolate({
				date:newDate.toString().gsub("-","_")
			})
			
			if(dateContainer = $(dateContainerId)){
				previousDateContainer = this.listItem.up('.events_for_date')
				
				this.listItem.remove()
				dateContainer.removeClassName('empty')
				dateContainer.down('ul').insert({top:r.responseText})
				this.setupNewEditor()
				
				if(!previousDateContainer.down('.event')){
					previousDateContainer.addClassName('empty')
				}
				
			}
			else {
				console.log("Date is off page, just remove it")
				this.listItem.remove()
				alert("Your changes were saved!")
			}
		}
		
		Overlay.dismiss()
	},
	setupNewEditor: function(){
		newListItem = $("event_" + this.eventData.id)
		new InlineEventEditor(newListItem.down('a.edit'))
	}
})