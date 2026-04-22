/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import ToggleController from "./toggle_controller"

const HTML_SIMPLE = `
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">Toggle</button>
  <div data-toggle-target="menu" class="hidden">Menu content</div>
</div>
`

const HTML_MOBILE = `
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">Toggle</button>
  <div data-toggle-target="menu" class="hidden">Desktop menu</div>
  <div data-toggle-target="mobileMenu" class="hidden">Mobile menu</div>
</div>
`

let application

function button() { return document.querySelector("button") }

beforeEach(async () => {
  application = Application.start()
  application.register("toggle", ToggleController)
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("ToggleController", () => {
  describe("with menu target only", () => {
    beforeEach(async () => {
      document.body.innerHTML = HTML_SIMPLE
      await new Promise(resolve => setTimeout(resolve, 0))
    })

    it("starts with menu hidden", () => {
      expect(document.querySelector('[data-toggle-target="menu"]').classList.contains("hidden")).toBe(true)
    })

    it("shows menu on first click", () => {
      button().click()
      expect(document.querySelector('[data-toggle-target="menu"]').classList.contains("hidden")).toBe(false)
    })

    it("hides menu on second click", () => {
      button().click()
      button().click()
      expect(document.querySelector('[data-toggle-target="menu"]').classList.contains("hidden")).toBe(true)
    })
  })

  describe("with mobileMenu target", () => {
    beforeEach(async () => {
      document.body.innerHTML = HTML_MOBILE
      await new Promise(resolve => setTimeout(resolve, 0))
    })

    it("toggles mobileMenu instead of menu", () => {
      const mobileMenu = document.querySelector('[data-toggle-target="mobileMenu"]')
      const desktopMenu = document.querySelector('[data-toggle-target="menu"]')

      button().click()
      expect(mobileMenu.classList.contains("hidden")).toBe(false)
      expect(mobileMenu.classList.contains("flex")).toBe(true)
      expect(desktopMenu.classList.contains("hidden")).toBe(true)
    })

    it("hides mobileMenu on second click", () => {
      const mobileMenu = document.querySelector('[data-toggle-target="mobileMenu"]')

      button().click()
      button().click()
      expect(mobileMenu.classList.contains("hidden")).toBe(true)
      expect(mobileMenu.classList.contains("flex")).toBe(false)
    })
  })
})
