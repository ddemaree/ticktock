var DimZum = {
  Version: "0.1"
};

DimZum.Controller = Class.create({
  initialize: function(options) {
    this.options = options || { };
    this.prefix  = options.prefix || "z";
    this.active  = false;

    document.observe("anchor:changed", this.onAnchorChanged.bind(this));
    document.observe("shade:clicked", this.onShadeClicked.bind(this));
    document.observe("viewport:resized", this.onViewportResized.bind(this));
    document.observe("keypress", this.onKeyPressed.bind(this));
  },

  getShade: function() {
    return this.shade = this.shade || new DimZum.Shade(this.options.shade);
  },

  getWindow: function() {
    return this.window = this.window || new DimZum.Window(this.options.window);
  },

  onAnchorChanged: function(event) {
    if (this.isActableAnchor(event.memo.to)) {
      var elements = this.getElementsFromAnchor(event.memo.to);
      this.showElement(elements.first());

    } else {
      this.hideActiveElement();
    }
  },

  onShadeClicked: function(event) {
    this.close();
  },

  onViewportResized: function(event) {
    if (this.active) {
      this.getShade().resizeElement();
      this.getWindow().repositionWindow();
    }
  },

  onKeyPressed: function(event) {
    if (this.active && event.keyCode == Event.KEY_ESC) {
      this.close();
      event.stop();
    }
  },

  isActableAnchor: function(anchor) {
    var components = (anchor || "").split("/");
    if (components[0] != this.prefix) return false;
    if (!$(components[1])) return false;
    return true;
  },

  getElementsFromAnchor: function(anchor) {
    return anchor.split("/").slice(1).map(function(id) { return $(id) });
  },

  showElement: function(element) {
    if (!this.active) this.getShade().show();
    this.getWindow().showWithContents(element);
    this.active = true;
  },

  hideActiveElement: function() {
    if (this.active) {
      this.getWindow().hide();
      this.getShade().hide();
      this.active = false;
    }
  },

  close: function() {
    window.location.hash = "#/";
    this.hideActiveElement();
  },

  clearPurgatory: function() {
    this.getWindow().clearPurgatory();
  }
});
DimZum.Shade = Class.create({
  initialize: function(options) {
    this.options = options || { };
    this.createElement();
    $(document.body).insert(this.element);
    this.element.observe("click", this.onClick.bind(this));
  },

  show: function() {
    this.resizeElement();
    this.element.show();
  },

  hide: function() {
    this.element.hide();
  },

  createElement: function() {
    this.element = new Element("div").hide();
    this.element.setStyle({
      position:   "absolute",
      top:        0,
      left:       0,
      background: this.options.background || "#000",
      opacity:    this.options.opacity || 0.50,
      zIndex:     this.options.zIndex || 1000
    });
  },

  resizeElement: function() {
    var dimensions = $(document.body).getDimensions();
    this.element.setStyle({
      width:  dimensions.width + "px",
      height: dimensions.height + "px"
    });
  },

  onClick: function(event) {
    this.element.fire("shade:clicked", { shade: this });
  }
});
DimZum.Window = Class.create({
  initialize: function(options) {
    this.options = options || { };
    this.createElements();
  },

  createElements: function() {
    if (this.options.element) {
      this.element  = this.options.element;
      this.viewport = this.element.down("div.viewport");

    } else {
      this.element  = new Element("div").hide();
      this.viewport = new Element("div").addClassName("viewport");
      this.controls = this.options.controls ||
        new Element("div").update('<a href="#/">Close</a>');

      this.element.insert(this.viewport);
      this.controls.show().addClassName("controls");
      this.element.insert(this.controls);
    }

    this.element.addClassName(this.options.className || "dim_zum_window");
    this.element.setStyle({
      position: "absolute",
      top:      0,
      left:     0,
      zIndex:   this.options.zIndex || 2000
    });

    this.purgatory = new Element("div").hide();

    $(document.body).insert(this.element);
    $(document.body).insert(this.purgatory);
  },

  showWithContents: function(contentElement) {
    this.adoptContents(contentElement);
    this.repositionWindow();
    this.element.show();
  },

  adoptContents: function(contentElement) {
    this.releaseContents();
    this.viewport.insert(contentElement);
    this.hasContents = true;
    contentElement.show();
  },

  getContents: function() {
    if (this.hasContents)
      return this.viewport.down();
  },

  releaseContents: function() {
    var contents = this.getContents();
    if (contents) {
      contents.hide();
      this.purgatory.insert(contents);
    }

    this.hasContents = false;
  },

  repositionWindow: function() {
    var windowDimensions   = this.element.getDimensions();
    var viewportDimensions = document.viewport.getDimensions();
    var viewportOffsets    = document.viewport.getScrollOffsets();

    var xOffsetFactor = this.options.xOffset || 0.5;
    var yOffsetFactor = this.options.yOffset || 0.5;

    var left = viewportDimensions.width * xOffsetFactor - windowDimensions.width * xOffsetFactor;
    var top  = viewportDimensions.height * yOffsetFactor - windowDimensions.height * yOffsetFactor;

		console.log(viewportDimensions.width)
		console.log(windowDimensions.width)
		console.log("left:#{left}, top:#{top}".interpolate({left:left,top:top}))

    this.element.setStyle({
      left: viewportOffsets.left + left + "px",
      top:  viewportOffsets.top + top + "px"
    });
  },

  hide: function() {
    this.releaseContents();
    this.element.hide();
  },

  clearPurgatory: function() {
    this.purgatory.update("");
  }
});