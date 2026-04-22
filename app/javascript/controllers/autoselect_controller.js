import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.setSelectionRange(0, this.element.value.length)
  }
}
