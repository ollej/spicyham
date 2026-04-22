/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import AlertController from "./alert_controller"

const HTML = `
<div data-controller="alert" role="alert" class="border rounded p-4">
  <span>Flash message</span>
  <button data-action="click->alert#dismiss">×</button>
</div>
`

let application

beforeEach(async () => {
  document.body.innerHTML = HTML
  application = Application.start()
  application.register("alert", AlertController)
  await new Promise(resolve => setTimeout(resolve, 0))
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("AlertController", () => {
  it("renders the alert", () => {
    expect(document.querySelector("[role=alert]")).not.toBeNull()
  })

  it("removes alert when dismiss is clicked", () => {
    document.querySelector("button").click()
    expect(document.querySelector("[role=alert]")).toBeNull()
  })

  it("removes alert from DOM entirely", () => {
    document.querySelector("button").click()
    expect(document.body.innerHTML.trim()).toBe("")
  })
})
