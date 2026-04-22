import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["api", "apiKey", "apiUser", "domain", "button", "processing", "success", "failed", "untested"]
  static values = { url: String }

  test(e) {
    e.preventDefault()
    this.processing()
    const data = new URLSearchParams({
      api: this.apiTarget.value,
      api_key: this.apiKeyTarget.value,
      api_user: this.apiUserTarget.value,
      domain: this.domainTarget.value,
    })
    const csrfToken = document.querySelector('meta[name="csrf-token"]')
    const headers = { "Content-Type": "application/x-www-form-urlencoded" }
    if (csrfToken) { headers["X-CSRF-Token"] = csrfToken.content }
    fetch(this.urlValue, {
      method: "POST",
      headers: headers,
      body: data,
    })
      .then(response => {
        if (response.ok) { this.success() } else { this.fail() }
      })
      .catch(() => this.fail())
  }

  processing() {
    this.reset()
    this.untestedTarget.classList.add("hidden")
    this.processingTarget.classList.remove("hidden")
  }

  success() {
    this.reset()
    this.buttonTarget.classList.add("border-green-600", "text-green-600")
    this.buttonTarget.classList.remove("border-gray-700", "text-gray-700")
    this.successTarget.classList.remove("hidden")
    this.untestedTarget.classList.add("hidden")
  }

  fail() {
    this.reset()
    this.buttonTarget.classList.add("border-red-600", "text-red-600")
    this.buttonTarget.classList.remove("border-gray-700", "text-gray-700")
    this.failedTarget.classList.remove("hidden")
    this.untestedTarget.classList.add("hidden")
  }

  reset() {
    this.buttonTarget.classList.add("border-gray-700", "text-gray-700")
    this.buttonTarget.classList.remove("border-green-600", "text-green-600", "border-red-600", "text-red-600")
    this.processingTarget.classList.add("hidden")
    this.successTarget.classList.add("hidden")
    this.failedTarget.classList.add("hidden")
    this.untestedTarget.classList.remove("hidden")
  }
}
