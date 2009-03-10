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