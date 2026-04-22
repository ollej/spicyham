import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "mobileMenu"]

  toggle() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.toggle("hidden")
      this.mobileMenuTarget.classList.toggle("flex")
    } else {
      this.menuTarget.classList.toggle("hidden")
    }
  }
}
