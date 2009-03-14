Object.extend(Ticktock, {
	timeToUnits: function(seconds){
		time = Number(seconds)
		unitsAsObject = {
			hours:   Math.floor(time/3600),
			minutes: Math.floor((time % 3600) / 60), 
			seconds: Math.floor(time % 60)
		}
		return unitsAsObject; 
	},
	timeToString: function(seconds){
		units = Ticktock.timeToUnits(seconds)
		output = []
		
		if(units.hours > 0)
			output.push(units.hours + "h")
		if(units.minutes > 0)
			output.push(units.minutes + "m")
			
		return output.join(" ")
	},
	eventMessage:function(string){
		return string.gsub(/\#(?:(\w+))\s*/,function(match){
			return '<a href="/events?tag=#{tag}" rel="tag" title="Events tagged with #{tag}">##{tag}</a> '.interpolate({tag:match[1]})
		})
	},
	zebraStripe:function(selector){
		x = 0
		$$(selector).each(function(elem){
			elem.removeClassName('even')
			elem.removeClassName('odd')
			elem.addClassName((x % 2 == 0) ? 'even' : 'odd')
			x += 1
		})
	}
})

Object.extend(Ticktock, {
	Subject:Class.create({
		initialize:function(obj){
			this.id 			= obj.id
			this.name 		= obj.name
			this.nickname = obj.nickname
		},
		toElement: function(){
			return '<strong class="subject"><a href="/trackables/#{id}/events">#{name}</a></strong>'.interpolate({
				id:this.id,
				name:(this.name||this.nickname)
			})
		}
	})
})

RecentEvents = {
	createEvent:function(event){
		$('errorContainer').hide()
		$('errorContainer').down('ul').update('')
		
		new Ajax.Request('/events.json', {
			asynchronous: true,
			method: 'post',
			parameters: Form.serialize('new_event'),
			evalJSON: true,
			onSuccess:function(response){
				event = response.responseJSON.event
				reRow = new RecentEvents.Row(event)
				
				$('recent-events').down('table').insert({top:reRow})
				Ticktock.zebraStripe('#recent-events tr')
				$('new_event').reset()
			},
			onFailure:function(response){
				errors = response.responseJSON
				ul = $('errorContainer').down('ul')
				
				errors.each(function(error){
					ul.insert('<li>#{field} #{errorDescription}</li>'.interpolate({
						field:error[0],
						errorDescription:error[1]
					}))
				})
				
				$('errorContainer').show()
			}
		})
		
		event.stop()
	},
	deleteEvent:function(link,elem){
		
		auth_token = $$('input[name=authenticity_token]')[0].value
		
		new Ajax.Request(link.href, {
			asynchronous:true, evalScripts:true, method:'delete',
			parameters:'authenticity_token=' + encodeURIComponent(auth_token),
			onSuccess:function(){
				link.up('tr').fade({
					duration:0.5,
					afterFinish:function(){
						link.up('tr').remove()
						Ticktock.zebraStripe('#recent-events tr')
					}
				})
			}
		})
	},
	Row: Class.create({
		template:new Template('<tr id="recent_event_#{eventId}"><td class="date"><span>#{date}</span></td><td class="duration">#{duration}</td><td class="body"><p>#{subject} #{body}</p></td><td class="actions"><a href="/events/#{eventId}/edit" class="edit">Edit</a> <a href="/events/#{eventId}" class="delete" onclick="RecentEvents.deleteEvent(this);return false;" rel="destroy">Delete</a></td></tr>'),

		initialize: function(row){
			this.event = row
			this.eventId  = this.event.id
			this.date     = CalendarDate.parse(this.event.date)
			this.body     = Ticktock.eventMessage(this.event.body)
			this.subject  = (this.event.subject ? new Ticktock.Subject(this.event.subject).toElement() : "")
			this.duration = Ticktock.timeToString(this.event.duration)
		},

		toElement:function(event){
			return this.template.evaluate(this)
		}

	})
}