//= require <prototype>

var Overlay = {
	invoke: function(options){
		this.element = $('overlay')
		
		this.options = Object.clone(options);
	    
	    if(!this.element){
				$(document.body).insert(new Element('div',{id:'overlay'}))
				this.element = $('overlay')
			}
		
		this.element.addClassName(this.options.className)
		
		this.element.observe('overlay:click', function(){
			this.dismiss()	
			var onClick = this.options.onClick;
			if (Object.isFunction(onClick)) onClick();
		}.bind(this))
		
		this.element.observe('click', function(event){
			overlay = event.findElement()
			overlay.fire("overlay:click")
		})
	},
	dismiss: function(){
		if(this.element){ this.element.remove() }
	}
}