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