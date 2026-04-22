import ClipboardJS from "clipboard/dist/clipboard"

document.addEventListener("DOMContentLoaded", function() {
  // Select default address
  const address = document.getElementById("address")
  if (address) {
    address.setSelectionRange(0, address.value.length)
  }

  new ClipboardJS(".copy-clipboard")

  // Navbar mobile toggle
  const toggler = document.querySelector("[data-navbar-toggle]")
  const nav = document.querySelector("[data-navbar-menu]")
  if (toggler && nav) {
    toggler.addEventListener("click", function() {
      nav.classList.toggle("hidden")
    })
  }

  // Alert dismiss
  document.querySelectorAll("[data-dismiss-alert]").forEach(function(btn) {
    btn.addEventListener("click", function() {
      btn.closest("[role=alert]").remove()
    })
  })

  // Dropdown toggle
  document.querySelectorAll("[data-dropdown-toggle]").forEach(function(btn) {
    const menu = btn.closest("[data-dropdown]").querySelector("[data-dropdown-menu]")
    btn.addEventListener("click", function(e) {
      e.stopPropagation()
      menu.classList.toggle("hidden")
    })
    document.addEventListener("click", function() {
      menu.classList.add("hidden")
    })
  })
})
