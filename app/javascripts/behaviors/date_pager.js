//= require <calendar_date>
//= require <calendar_date_select>

Object.extend(Ticktock, {
	DatePager: Class.create({
		initialize: function(field, container){
			this.field     = $(field)
			this.container = $(container)
			
			if(p = this.field.up('p.field'))
				p.hide()
			
			this.changeDate(CalendarDate.parse())
			
			this.createPagerBar()
			
			// 2 days ago
			prevDate = this.date.previous(2)
			this.addDateToPagerBar(this.shorterDate(prevDate), prevDate)
			
			prevDate = this.date.previous(1)
			this.addDateToPagerBar(this.shorterDate(prevDate), prevDate)
			
			this.addDateToPagerBar("Today", this.date)
			
			this.addArbitraryDatePicker()
		},
		createPagerBar: function(){
			console.log("Creating pager bar")
			this.pager = new Element('div', {className:'qe-datepager clearfix'})
			this.container.insert({top:this.pager})
		},
		addDateToPagerBar:function(text,date){
			date = CalendarDate.parse(date)
			
			link = new Element('a', {href:'javascript:void%200',className:'tab',id:('dt'+date.toString())})
			link.writeAttribute('date', date)
			
			if(date.equals(this.date))
				link.addClassName('selected')
			
			link.update(text)
			
			link.observe('click', function(e){
				link = e.findElement()
				this.pager.select('.tab').invoke('removeClassName','selected')
				link.addClassName('selected')
				
				date = CalendarDate.parse(link.getAttribute('date'))
				this.changeDate(date)
				e.stop()
			}.bind(this))
			
			this.pager.insert({bottom:link})
		},
		changeDate: function(date){
			this.date = date
			this.field.setValue(this.date)
			
			if(this.pickerToggle)
				this.pickerToggle.update("Other date&hellip;")
			
			if(this.calendar)
				this.hideCalendar()
				
			//if(this.datePicker)
				//this.datePicker.element.fire("calendar:dateSelected", { date: this.date })
		},
		addArbitraryDatePicker: function(){
			this.datePicker = new CalendarDateSelect(this.field)
			this.pickerContainer = new Element('div', {className:'picker tab other'})
			
			
			this.pickerContainer.makePositioned()
			this.pickerContainer.insert({top:this.datePicker})
			
			this.calendar = this.pickerContainer.down('.calendar_date_select')
			this.calendar.hide()
			
			this.calendar.observe("calendar:dateSelected", function(e){
				this.hideCalendar()
				this.updateDescriptionFromPicker()
			}.bind(this))
			
			this.pickerToggle = new Element('a', {href:'javascript:void%200', className:'toggle'})
			this.pickerToggle.update('Other date&hellip;')
			this.pickerContainer.insert({top:this.pickerToggle})
			this.pickerOpen = false
			
			this.pickerToggle.observe('click', function(e){
				link = e.findElement()
				
				if(this.pickerOpen)
					this.hideCalendar()
				else
					this.showCalendar()
			}.bind(this))
			
			this.pager.insert({bottom:this.pickerContainer})
		},
		showCalendar: function(){
			//this.opened = true
			this.calendar.show()
			this.pickerToggle.addClassName('open')
			this.pickerOpen = true
			
			if(!$('overlay')){
				$(document.body).insert(new Element('div',{id:'overlay'}))
				$('overlay').observe('click', function(){
					this.hideCalendar()
				}.bind(this))
			}
		},
		hideCalendar: function(){
			this.calendar.hide()
			this.pickerToggle.removeClassName('open')
			this.pickerOpen = false
			if($('overlay')){ $('overlay').remove() }
		},
		updateDescriptionFromPicker: function(){
			this.changeDate(this.datePicker.date)
			this.pager.select('.tab').invoke('removeClassName','selected')
			
			if(tab = $(('dt'+this.date.toString()))) {
				console.log("Existing tab")
				tab.addClassName('selected')
				this.pickerToggle.update('Other date&hellip;')
			}
			else {
				
				this.pickerToggle.up('.tab').addClassName('selected')
				this.pickerToggle.update(this.shorterDate(this.datePicker.date));
			}
			
			
			
		},
		shorterDate: function(date){
			return "#{month} #{day}".interpolate({
	    	 	month: date.getMonthName(),
				day:   date.day
		   })
		}
	})
})