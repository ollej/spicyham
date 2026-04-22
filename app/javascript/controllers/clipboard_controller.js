import { Controller } from "@hotwired/stimulus"
import ClipboardJS from "clipboard/dist/clipboard"

export default class extends Controller {
  connect() {
    this.clipboard = new ClipboardJS(this.element)
    this.clipboard.on("success", () => {
      const original = this.element.innerHTML
      this.element.innerHTML = "Copied!"
      this.element.classList.add("border-green-500", "text-green-400")
      this.element.classList.remove("border-gray-600", "text-gray-300")
      setTimeout(() => {
        this.element.innerHTML = original
        this.element.classList.remove("border-green-500", "text-green-400")
        this.element.classList.add("border-gray-600", "text-gray-300")
      }, 1500)
    })
  }

  disconnect() {
    if (this.clipboard) this.clipboard.destroy()
  }
}
