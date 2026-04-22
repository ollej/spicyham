import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "input", "submit"]
  static values = { phrase: { type: String, default: "DELETE" } }

  reveal() {
    this.submitTarget.disabled = true
    this.inputTarget.value = ""
    this.dialogTarget.showModal()
    this.inputTarget.focus()
  }

  verify() {
    this.submitTarget.disabled = this.inputTarget.value !== this.phraseValue
  }

  cancel() {
    this.dialogTarget.close()
  }
}
