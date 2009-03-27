var EventManager = {
	rows:[],
	setup: function(){
		$$('.event').each(function(row){
			new EventManager.Row(row)
		})
	},
	endAll: function(){
		$$('.event').invoke('removeClassName','editing')
	}
}

EventManager.Row = Class.create({
	initialize: function(row){
		this.element = row
		EventManager.rows.push(this)
		
		this.editLink   = this.element.down('a.edit')
		this.deleteLink = this.element.down('a.delete')
		this.cancelLink = this.element.down('a.cancel')
		
		this.cancelLink.observe('click', this.endEditing.bind(this))
		this.editLink.observe('click',this.beginEditing.bind(this))
	},
	beginEditing: function(e){
		EventManager.endAll()
		
		if(!this.element.hasClassName('editing')){
			this.element.addClassName('editing')
		}
		
		e.stop()
	},
	endEditing: function(e){
		this.element.removeClassName('editing')
		e.stop()
	}
})

Event.observe(window, 'load', EventManager.setup)