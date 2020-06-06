(function() {
  var el = document.createElement("a");
  el.href = "https://spicyham.net?email=" + encodeURIComponent(window.location);
  el.setAttribute("target", "_blank");
  el.click();
})();
