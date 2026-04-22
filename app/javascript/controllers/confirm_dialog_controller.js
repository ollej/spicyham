import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "message", "destinations", "form"]

  open(e) {
    e.preventDefault()
    const { label, destinations, url } = e.currentTarget.dataset
    this.messageTarget.textContent = label
    if (this.hasDestinationsTarget && destinations) {
      this.destinationsTarget.textContent = destinations
    }
    this.formTarget.action = url
    this.dialogTarget.showModal()
  }

  cancel() {
    this.dialogTarget.close()
  }
}
