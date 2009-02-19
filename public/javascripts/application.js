// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var TicktockGhostLabel = Class.create({
	initialize: function(id){
		this.wrapper = $(id)
		this.wrapper.makePositioned()
		
		this.field = this.wrapper.down('input')
		this.label = this.wrapper.down('label')
		
		this.label.addClassName('ghost')
		this.label.setStyle("position:absolute;top:0;left:0;z-index:22;")
		
		this.label.setStyle({
			width:this.field.getWidth() + "px",
			height:this.field.getHeight() + "px"
		})
		
		this.label.observe('click', this.handleLabelClick.bind(this))
		this.field.observe('blur', this.handleFieldBlur.bind(this))
	},
	handleLabelClick: function(event){
		console.log("Clicky click")
		this.field.focus()
		this.label.hide()
		event.stop()
	},
	handleFieldBlur: function(event){
		if($F(this.field).blank()){
			console.log("BLURRY")
			this.label.show()
		}
	}
})


var TicktockDateSelect = Class.create({
	initialize: function(id){
		calendarId = 'calendar_for_' + id
		
		this.field    = $(id)
		this.container = this.field.wrap(new Element('div', {className: 'cds-container', id: 'cds_container_for_' + id}))
		this.field.hide()
		
		console.log(this.field.getWidth())
		
		new CalendarDateSelect(id)
		this.calendar = $(calendarId)
		this.description = new Element('a',{className:'description'})
		this.field.insert({after:this.description})
		this.description.setAttribute('href','javascript:void%200')
		
		this.opened = false
		this.hideCalendar()
		this.calendar.makePositioned()
		
		this.description.observe('click', function(e){
			if(this.opened)
				this.hideCalendar()
			else
				this.showCalendar()
		}.bind(this))
		
		this.calendar.observe("calendar:dateSelected", function(e){
			this.hideCalendar()
		}.bind(this))
	},
	showCalendar: function(){
		this.opened = true
		this.calendar.show()
		this.container.addClassName('open')
		
		if(!$('overlay')){
			$(document.body).insert(new Element('div',{id:'overlay'}))
			$('overlay').observe('click', function(){
				this.hideCalendar()
			}.bind(this))
		}
	},
	hideCalendar: function(){
		this.opened = false
		this.calendar.hide()
		this.updateDescription()
		this.container.removeClassName('open')
		if($('overlay')){ $('overlay').remove() }
	},
	updateDescription: function(){
		this.date = this.field.widget.date
		
		this.description.update("#{month} #{day}, #{year}".interpolate({
    	 month: this.date.getMonthName(), day: this.date.day, year: this.date.year
	   }));
		
	}
})