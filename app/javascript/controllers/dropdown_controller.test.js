/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import DropdownController from "./dropdown_controller"

const HTML = `
<div data-controller="dropdown">
  <button data-action="click->dropdown#toggle">Open</button>
  <div data-dropdown-target="menu" class="hidden">
    <a href="#">Item 1</a>
    <a href="#">Item 2</a>
  </div>
</div>
<div id="outside">Outside element</div>
`

let application

function menu() { return document.querySelector('[data-dropdown-target="menu"]') }
function button() { return document.querySelector("button") }

beforeEach(async () => {
  document.body.innerHTML = HTML
  application = Application.start()
  application.register("dropdown", DropdownController)
  await new Promise(resolve => setTimeout(resolve, 0))
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("DropdownController", () => {
  it("starts with menu hidden", () => {
    expect(menu().classList.contains("hidden")).toBe(true)
  })

  it("shows menu on click", () => {
    button().click()
    expect(menu().classList.contains("hidden")).toBe(false)
  })

  it("hides menu on second click", () => {
    button().click()
    button().click()
    expect(menu().classList.contains("hidden")).toBe(true)
  })

  it("closes menu when clicking outside", () => {
    button().click()
    expect(menu().classList.contains("hidden")).toBe(false)

    document.getElementById("outside").click()
    expect(menu().classList.contains("hidden")).toBe(true)
  })

  it("does not close when clicking inside the dropdown", () => {
    button().click()
    menu().querySelector("a").click()
    expect(menu().classList.contains("hidden")).toBe(false)
  })
})
