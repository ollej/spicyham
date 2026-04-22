document.addEventListener("DOMContentLoaded", function() {
  // Select default address
  const address = document.getElementById("address")
  if (address) {
    address.setSelectionRange(0, address.value.length)
  }
})
