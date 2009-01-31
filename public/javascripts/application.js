// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

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