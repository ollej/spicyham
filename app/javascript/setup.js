import ClipboardJS from "clipboard/dist/clipboard"

document.addEventListener("DOMContentLoaded", function() {
  // Fix input element click problem
  document.querySelectorAll('.dropdown-menu form').forEach(function(el) {
    el.addEventListener('click', function(e) { e.stopPropagation() })
  })
  document.querySelectorAll('.dropdown-menu').forEach(function(el) {
    el.addEventListener('touchstart', function(e) { e.stopPropagation() })
  })

  // Instantiate Twitter Combobox plugin (still uses jQuery)
  if (window.jQuery) {
    window.jQuery('.combobox').combobox({
      clearIfNoMatch: false,
      bsVersion: '4',
      iconCaret: 'dropdown-toggle',
      freeform: true
    })
  }

  // Select default address
  const address = document.getElementById("address")
  if (address) {
    address.setSelectionRange(0, address.value.length)
  }

  new ClipboardJS(".copy-clipboard")
})
