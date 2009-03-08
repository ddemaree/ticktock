// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var Ticktock = {
	GhostLabel: Class.create({
		initialize: function(id){
			this.wrapper = $(id)
			this.wrapper.makePositioned()

			this.field = this.wrapper.down('input, textarea')
			this.label = this.wrapper.down('label')

			this.label.addClassName('ghost')
			this.label.setStyle("position:absolute;top:0;left:0;z-index:22;")

			this.label.observe('click', this.handleLabelClick.bind(this))
			this.field.observe('blur', this.handleFieldBlur.bind(this))
			this.field.observe('focus', this.handleFieldFocus.bind(this))
		},
		handleFieldFocus: function(event){
			this.label.hide()
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
}

Object.extend(Ticktock, {
	BarChart: Class.create({
		initialize: function(id,options){
			this.canvas = $(id)
			this.context = this.canvas.getContext('2d')
			
			this.options = {
				data: [],
				colors: []
	    };
	    Object.extend(this.options, options || { });
			
			this.data = this.options.data
			//console.log(this.data.sort(function(a,b){return b-a;}))
			
			maxValue = this.data.sort(function(a,b){return b-a;})[0]
			this.ceiling = (this.options.ceiling || maxValue)
			
			// this.context.beginPath()
			// this.context.setFillColor('white')
			// this.context.fillRect(0,0,300,120)
			// this.context.closePath()
			
			for(x = 0; value = this.data[x]; x++) {
				this.drawBar(value,x)
			}
			
			this.context.beginPath()
			this.context.setStrokeColor('000000')
			this.context.setLineWidth(1)
			this.context.moveTo(5,120)
			this.context.lineTo(295,120)
			this.context.stroke()
			//this.context.strokeRect(10,100,300,1)
			
			this.context.closePath()
			
			this.canvas.setStyle("width:100%")
		},
		drawBar: function(value, offset){
			
			availableWidth = Math.floor((300 - 20) -  (this.data.length * 3))
			
			barAndSpacer = Math.floor(availableWidth / this.data.length) + 3
			barWidth     = barAndSpacer - 3
			
			left   = (offset * barAndSpacer) + 10
			height = Math.floor((value / this.ceiling) * 120) - 2
			top  	 = (this.canvas.getHeight() - height) + 1
			
			this.context.setStrokeColor('000000')
			this.context.setLineWidth(2)
			
		
			this.context.beginPath()
			
			
			this.context.rect(left,top,barWidth,height)
			console.log(this.context.shadowOffsetX = 1)
			console.log(this.context.shadowOffsetY = 1)
			console.log(this.context.shadowColor = '333')
			
			//this.context.clearShadow()
			//this.context.strokeRect(left,top,barWidth,height)
			this.context.closePath()
			this.context.setFillColor(this.options.colors[offset] || "888");
			this.context.fill();
			
			
		}
	})
})



function pieGraph(c) {
	console.log($('tags_chart').getHeight())
	
	var i,
		pi = Math.PI,
		angles = [0, 1, 2, 3, 4, 2*pi];

	// reset canvas
	c.clearRect(0,0,75,75);
	c.globalAlpha = 1;

	// calculate random contiguous angles whose sum is 2*pi
	for (i = 1; i < 5; i++) {
		angles[i] = Math.random() * (2*pi - angles[i-1]) + angles[i-1];
	}

	// circle sectors
	c.fillStyle = '#060';
	for (i = 0; i < 5; i++) {
		c.beginPath();
		c.moveTo(75,75);
		c.arc(75, 75, 75, angles[i], angles[i+1], false);
		c.closePath();
		c.fill();
		c.globalAlpha -= 0.15;
	}
}


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