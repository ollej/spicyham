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
    this.untestedTarget.classList.add("d-none")
    this.processingTarget.classList.remove("d-none")
  }

  success() {
    this.reset()
    this.buttonTarget.classList.remove("btn-outline-dark")
    this.buttonTarget.classList.add("btn-outline-success")
    this.successTarget.classList.remove("d-none")
    this.untestedTarget.classList.add("d-none")
  }

  fail() {
    this.reset()
    this.buttonTarget.classList.remove("btn-outline-dark")
    this.buttonTarget.classList.add("btn-outline-danger")
    this.failedTarget.classList.remove("d-none")
    this.untestedTarget.classList.add("d-none")
  }

  reset() {
    this.buttonTarget.classList.add("btn-outline-dark")
    this.buttonTarget.classList.remove("btn-outline-danger", "btn-outline-success")
    this.processingTarget.classList.add("d-none")
    this.successTarget.classList.add("d-none")
    this.failedTarget.classList.add("d-none")
    this.untestedTarget.classList.remove("d-none")
  }
}
