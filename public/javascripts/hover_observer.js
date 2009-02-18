Element.addMethods({
  upwards: function(element, iterator) {
    while (element = $(element)) {
      if (iterator(element)) return element;
      element = element.parentNode;
    }
  }
});

var HoverObserver = Class.create();

Object.extend(HoverObserver, {
  Options: {
    activationDelay:    0,
    deactivationDelay:  0.5,
    targetClassName:    "hover_target",
    containerClassName: "hover_container",
    activeClassName:    "hover"
  }
});

Object.extend(HoverObserver.prototype, {
  initialize: function(element, options) {
    this.element = $(element);
    this.options = Object.extend(Object.clone(HoverObserver.Options), options || {});
    this.start();
  },
  
  start: function() {
    if (!this.observers) {
      this.observers = $w("mouseover mouseout").map(function(name) {
        var handler = this["on" + name.capitalize()].bind(this);
        Event.observe(this.element, name, handler);
        return { name: name, handler: handler };
      }.bind(this));
    }
  },
  
  stop: function() {
    if (this.observers) {
      this.observers.each(function(info) {
        Event.stopObserving(this.element, info.name, info.handler);
      }.bind(this));
      delete this.observers;
    }
  },
  
  onMouseover: function(event) {
    var element   = this.activeHoverElement = Element.extend(Event.element(event));
    var container = this.getContainerForElement(element);

    if (container) {
      if (this.activeContainer) {
        this.activateContainer(container);
      } else {
        this.startDelayedActivation(container);
      }
    } else {
      this.startDelayedDeactivation();
    }
  },
  
  onMouseout: function(event) {
    delete this.activeHoverElement;
    this.startDelayedDeactivation();
  },
  
  activateContainer: function(container) {
    this.stopDelayedDeactivation();
    
    if (this.activeContainer) {
      if (this.activeContainer == container) return;
      this.deactivateContainer();
    }
    
    this.activeContainer = container;
    this.activeContainer.addClassName(this.options.activeClassName);
  },
  
  deactivateContainer: function() {
    if (this.activeContainer) {
      this.activeContainer.removeClassName(this.options.activeClassName);
      delete this.activeContainer;
    }
  },
  
  startDelayedActivation: function(container) {
    if (this.options.activationDelay) {
      (function() {
        if (container == this.getContainerForElement(this.activeHoverElement))
          this.activateContainer(container);
        
      }).bind(this).delay(this.options.activationDelay);
    } else {
      this.activateContainer(container);
    }
  },
  
  startDelayedDeactivation: function() {
    if (this.options.deactivationDelay) {
      this.deactivationTimeout = this.deactivationTimeout || function() {
        var container = this.getContainerForElement(this.activeHoverElement);
        if (!container || container != this.activeContainer)
          this.deactivateContainer();
        
      }.bind(this).delay(this.options.deactivationDelay);
    } else {
      this.deactivateContainer();
    }
  },
  
  stopDelayedDeactivation: function() {
    if (this.deactivationTimeout) {
      window.clearTimeout(this.deactivationTimeout);
      delete this.deactivationTimeout;
    }
  },
  
  getContainerForElement: function(element) {
    if (!element) return;
    
    if (element.hasAttribute && !element.hasAttribute("hover_container")) {
      var target    = this.getTargetForElement(element);
      var container = this.getContainerForTarget(target);
      this.cacheContainerFromElementToTarget(container, element, target);
    }
    
    return $(element.readAttribute("hover_container"));
  },
  
  getTargetForElement: function(element) {
    if (!element) return;
    var targetClassName = this.options.targetClassName;
    return element.upwards(function(e) {
      if (e.hasClassName) 
        return e.hasClassName(targetClassName);
    });
  },
  
  getContainerForTarget: function(element) {
    if (!element) return;
    var containerClassName = this.options.containerClassName;
    return element.upwards(function(e) {
      if (e.hasClassName)
        return e.hasClassName(containerClassName);
    });
  },
  
  cacheContainerFromElementToTarget: function(container, element, target) {
    if (container && target) {
      if (!container.id) container.id = "hover_container_" + new Date().getTime();
      element.upwards(function(e) {
        e.writeAttribute("hover_container", container.id);
        if (e == target) return true;
      });
    }
  }
});