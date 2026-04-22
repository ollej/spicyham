class TestApi {
  constructor(selector) {
    this.element = document.querySelector(selector)
  }

  setup() {
    if (!this.element) return
    this.element.addEventListener('click', this.test.bind(this))
    document.querySelectorAll("#user_api, #user_api_key, #user_api_user, #user_domain").forEach(el => {
      el.addEventListener('change', this.reset.bind(this))
    })
  }

  test(e) {
    e.preventDefault()
    this.processing()
    const data = new URLSearchParams({
      api: this.fieldValue("user_api"),
      api_key: this.fieldValue("user_api_key"),
      api_user: this.fieldValue("user_api_user"),
      domain: this.fieldValue("user_domain"),
    })
    const csrfToken = document.querySelector('meta[name="csrf-token"]')
    const headers = { "Content-Type": "application/x-www-form-urlencoded" }
    if (csrfToken) { headers["X-CSRF-Token"] = csrfToken.content }
    fetch(this.element.dataset.testApiUrl, {
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
    this.element.querySelectorAll(".test-api-untested").forEach(el => el.classList.add("d-none"))
    this.element.querySelectorAll(".test-api-processing").forEach(el => el.classList.remove("d-none"))
  }

  success() {
    this.reset()
    this.element.classList.remove("btn-outline-dark")
    this.element.classList.add("btn-outline-success")
    this.element.querySelectorAll(".test-api-success").forEach(el => el.classList.remove("d-none"))
    this.element.querySelectorAll(".test-api-untested").forEach(el => el.classList.add("d-none"))
  }

  fail() {
    this.reset()
    this.element.classList.remove("btn-outline-dark")
    this.element.classList.add("btn-outline-danger")
    this.element.querySelectorAll(".test-api-failed").forEach(el => el.classList.remove("d-none"))
    this.element.querySelectorAll(".test-api-untested").forEach(el => el.classList.add("d-none"))
  }

  fieldValue(id) {
    return document.getElementById(id).value
  }

  reset() {
    this.element.classList.add("btn-outline-dark")
    this.element.classList.remove("btn-outline-danger", "btn-outline-success")
    this.element.querySelectorAll(".test-api-icon").forEach(el => el.classList.add("d-none"))
    this.element.querySelectorAll(".test-api-untested").forEach(el => el.classList.remove("d-none"))
  }
}

if (typeof module !== "undefined") module.exports = TestApi
