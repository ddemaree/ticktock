var AnchorObserver = {
  enabled:  true,
  interval: 0.1
};

document.observe("dom:loaded", function() {
  var lastAnchor = "";

  function poll() {
    var anchor = (window.location.hash || "").slice(1);
    if (anchor != lastAnchor) {
      document.fire("anchor:changed", { to: anchor, from: lastAnchor });
      lastAnchor = anchor;
    }
  }

  if (AnchorObserver.enabled) {
    setInterval(poll, AnchorObserver.interval * 1000);
  }
});
(function() {
  var emptyAnchorHandler;
  function getEmptyAnchorHandler() {
    return emptyAnchorHandler = emptyAnchorHandler ||
      new Element("a").writeAttribute({
        name:       "/"
      }).setStyle({
        position:   "absolute",
        visibility: "hidden"
      });
  }

  document.observe("click", function(event) {
    var element = event.findElement("a[href=#/]");
    if (element) {
      var offsets = document.viewport.getScrollOffsets();
      $(document.body).insert(getEmptyAnchorHandler().setStyle({
        left: offsets.left + "px",
        top:  offsets.top + "px"
      }));
    }
  });
})();
Event.observe(window, "resize", function(event) {
  document.fire("viewport:resized");
});