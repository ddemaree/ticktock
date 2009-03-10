//= require <calendar_date>
//= require <calendar_date_select>
//= require <overlay>

var TicktockDateSelect = Class.create({
	initialize: function(id){
		this.field = $(id)
		
		this.container = this.field.wrap(new Element('div', {className: 'cds-container tt-inline-date', id: 'cds_container_for_' + this.field.id}))
		this.field.hide()
		
		this.cds = new CalendarDateSelect(this.field)
		this.calendar = this.cds.toElement()
		this.container.insert({top:this.calendar})
		
		this.description = new Element('a', {className:'description',href:"#"})
		this.container.insert({top:this.description})
		
		this.opened = false
		
		this.hideCalendar()
		this.description.observe('click', this.handleClick.bind(this))
		this.calendar.observe("calendar:dateSelected", this.hideCalendar.bind(this))
	},
	handleClick: function(e){
		if(this.opened)
			this.hideCalendar()
		else
			this.showCalendar()
			
		e.stop()
	},
	showCalendar: function(e){
		this.opened = true
		this.calendar.show()
		this.container.addClassName('open')
		
		Overlay.invoke({className:'trans',onClick:function(){
			this.hideCalendar()
		}.bind(this)})
	},
	hideCalendar: function(e){
		this.opened = false
		this.calendar.hide()
		this.updateDescription()
		this.container.removeClassName('open')
		
		Overlay.dismiss()
	},
	updateDescription: function(){
		this.date = this.cds.date
		
		this.description.update("#{month}/#{day}/#{year}".interpolate({
			month: this.date.month, day: this.date.day, year: this.date.year
		}));
	}
})

Object.extend(Ticktock, {DateSelect:TicktockDateSelect})