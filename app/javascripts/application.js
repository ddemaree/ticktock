var Ticktock = {}

if(!console){
	var console = {
		log:function(mesg){
			/* Do nothing */
		}
	}
}

//= require <prototype>
//= require <effects>
//= require <calendar_date>

//= require "helpers/events_helper"

//= require "behaviors/ghost_label"
//# require "behaviors/canvas_drawing"
//= require "behaviors/inline_date_select"
//= require "behaviors/date_pager"
//= require "behaviors/hover_observer"
//= require "behaviors/inline_event_editor"

// Object.extend(Ticktock, {
// 	
// })

Event.observe(window, 'load', function(){
	QuickBox.setup()
})

var QuickBox = {
	setup:function(){
		if(!$('modals'))
			$(document.body).insert({bottom:new Element('div',{id:'modals'})})
			
		$$('a.quickbox').each(function(link){
			if(link.getAttribute('href').match(/^#/))
				link.observe('click', QuickBox.invoke.bind(link))
			else
				link.observe('click', QuickBox.invokeRemote.bind(link))
		})
	},
	hideAll:function(){
		$('modals').hide()
		$$('.modal').invoke('hide')
		if($('overlay')){ $('overlay').remove() }
	},
	invoke:function(event){
		href = this.getAttribute('href')
		new QuickBox.Base(href.gsub(/^#/,""))
		event.stop()
	},
	invokeRemote:function(event){
		event.stop()
	}
}

QuickBox.Base = Class.create({
	initialize: function(element, options){
		QuickBox.hideAll()
		
		this.element = $(element)
		this.element.addClassName('modal')
		
		// Set up overlay
		this.overlay = new Element('div',{id:'overlay',style:'display:none'})
		this.element.insert({before:this.overlay})		
		this.overlay.observe('click',this.hide.bind(this))
		
		this.show()
	},
	show:function(){
		this.overlay.show()
		this.element.show()
		this.center()
		$('modals').show()
	},
	hide:function(){
		this.element.removeClassName('modal')
		this.element.hide()
		this.overlay.remove()
	},
	center:function(){
		this.overlay.setStyle('position:fixed;z-index:9998')
		this.element.setStyle('position:fixed;z-index:9999')
		
		windowDimensions  = document.viewport.getDimensions()
		scrollOffsets     = document.viewport.getScrollOffsets()
		elementDimensions = this.element.getDimensions()
		
		setX = Math.round((windowDimensions.width - elementDimensions.width) / 2);
		setY = Math.round((windowDimensions.height - elementDimensions.height) / 2) + scrollOffsets.top;
		
		//console.log(setX + ' ' + setY)
		this.element.setStyle({
			left: setX + 'px',
			top:  setY + 'px'
		})
	}
})

var FrameMaker = {
	setup:function(){
		if(frame = $('workspace').down('.ws-frame')){
			this.frame = frame
			this.frame.insert({top:'<table><tr valign="top"><td><div class="f-spacer"> </div></td><td rowspan="2"><div class="f-gutter"> </div></td><td class="f-side" rowspan="2"></td></tr><tr><td class="f-main"></td></tr></table>'})
			
			this.mainContent = this.frame.down('.ws-main')
			this.frame.down('.f-main').appendChild(this.mainContent)

			this.sidebarContent = this.frame.down('.ws-sidebar')
			this.frame.down('.f-side').appendChild(this.sidebarContent)
			
			this.gutter = this.frame.down('.f-gutter')
			
			this.setSpacerWidth()
			Event.observe(window, 'resize', this.setSpacerWidth.bind(this))
		}
	},
	onResize:function(){
		
	},
	setSpacerWidth:function(){
		frameWidth  = this.frame.getWidth()
		gutterWidth = this.gutter.getWidth()
		sideWidth   = this.sidebarContent.getWidth()
		
		this.mainWidth = (frameWidth - gutterWidth - sideWidth)
		
		this.frame.down('.f-spacer').setStyle({
			width:this.mainWidth+'px'
		})
	}
}

