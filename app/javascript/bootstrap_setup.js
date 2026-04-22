document.addEventListener("DOMContentLoaded", function() {
  // Bootstrap 4 popover and tooltip initialization requires jQuery
  if (window.jQuery) {
    window.jQuery("a[rel~=popover], .has-popover").popover()
    window.jQuery("a[rel~=tooltip], .has-tooltip").tooltip()
  }
})
