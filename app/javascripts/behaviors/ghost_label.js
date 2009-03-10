Object.extend(Ticktock, {
	GhostLabel: Class.create({
		initialize: function(id){
			this.wrapper = $(id)
			this.wrapper.makePositioned()

			this.field = this.wrapper.down('input, textarea')
			this.label = this.wrapper.down('label, .label')

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
})