/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import ToggleController from "./toggle_controller"

const HTML = `
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">Toggle</button>
  <div data-toggle-target="menu" class="hidden">Menu content</div>
</div>
`

let application

function menu() { return document.querySelector('[data-toggle-target="menu"]') }
function button() { return document.querySelector("button") }

beforeEach(async () => {
  document.body.innerHTML = HTML
  application = Application.start()
  application.register("toggle", ToggleController)
  await new Promise(resolve => setTimeout(resolve, 0))
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("ToggleController", () => {
  it("starts with menu hidden", () => {
    expect(menu().classList.contains("hidden")).toBe(true)
  })

  it("shows menu on first click", () => {
    button().click()
    expect(menu().classList.contains("hidden")).toBe(false)
  })

  it("hides menu on second click", () => {
    button().click()
    button().click()
    expect(menu().classList.contains("hidden")).toBe(true)
  })
})
