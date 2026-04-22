import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "option", "hidden"]

  connect() {
    this.open = false
    document.addEventListener("click", this.outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClick)
  }

  outsideClick = (e) => {
    if (!this.element.contains(e.target)) this.close()
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase()
    this.optionTargets.forEach(option => {
      const text = option.textContent.toLowerCase()
      option.classList.toggle("hidden", query.length > 0 && !text.includes(query))
    })
    this.show()
  }

  select(e) {
    const value = e.currentTarget.dataset.value
    this.inputTarget.value = value
    this.hiddenTarget.value = value
    this.close()
  }

  toggle() {
    this.open ? this.close() : this.show()
  }

  show() {
    this.listTarget.classList.remove("hidden")
    this.open = true
  }

  close() {
    this.listTarget.classList.add("hidden")
    this.open = false
  }

  commit() {
    this.hiddenTarget.value = this.inputTarget.value
  }
}
