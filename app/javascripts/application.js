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

var Quickbox = {
	setup:function(){
		if(!$('tt-quickbox')){
			this.element = new Element('div', {id:'tt-quickbox'})
			$(document.body).insert(this.element)
		}
		return this.element
	},
	update:function(content){
		element = Quickbox.setup()
		element.update(content)
	},
	remote:function(link, options){
		this.link = link
		
		ajax_options = {
			asynchronous: true,
			evalScripts:  true,
			method: 'get',
			onSuccess:function(){
				this.element.show()
				this.position(this.link)
			}.bind(this)
		}
		Object.extend(ajax_options, (options || {}))
		
		element = Quickbox.setup()
		//element.hide()
		new Ajax.Updater(element, link.href, ajax_options)
	},
	teardown:function(){
		if(!$('tt-quickbox')){
			$('tt-quickbox').remove()
		}
	},
	position:function(link, options){
		topPos  = link.getHeight() + link.viewportOffset().top
		leftPos = link.viewportOffset().left
		
		pos_options = {
			position: 'auto',
			top:       topPos,
			left:      leftPos
		}
		Object.extend(pos_options, (options || {}))
		
		this.element.setStyle({
			position: 'absolute',
			display:  'block',
			top: 			 topPos + 'px',
			left: 		 leftPos + 'px'
		})
	}
}