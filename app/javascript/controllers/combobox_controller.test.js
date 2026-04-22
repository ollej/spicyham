/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import ComboboxController from "./combobox_controller"

const HTML = `
<div data-controller="combobox">
  <input type="hidden" name="destinations" data-combobox-target="hidden" value="">
  <input type="text" data-combobox-target="input"
    data-action="input->combobox#filter focus->combobox#show change->combobox#commit"
    value="" autocomplete="off">
  <ul data-combobox-target="list" class="hidden">
    <li data-combobox-target="option" data-value="alice@example.com" data-action="click->combobox#select">alice@example.com</li>
    <li data-combobox-target="option" data-value="bob@example.com" data-action="click->combobox#select">bob@example.com</li>
    <li data-combobox-target="option" data-value="carol@example.com" data-action="click->combobox#select">carol@example.com</li>
  </ul>
</div>
`

let application

function input() { return document.querySelector('[data-combobox-target="input"]') }
function hidden() { return document.querySelector('[data-combobox-target="hidden"]') }
function list() { return document.querySelector('[data-combobox-target="list"]') }
function options() { return document.querySelectorAll('[data-combobox-target="option"]') }

beforeEach(async () => {
  document.body.innerHTML = HTML
  application = Application.start()
  application.register("combobox", ComboboxController)
  await new Promise(resolve => setTimeout(resolve, 0))
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("ComboboxController", () => {
  it("starts with list hidden", () => {
    expect(list().classList.contains("hidden")).toBe(true)
  })

  it("shows list on focus", () => {
    input().dispatchEvent(new Event("focus"))
    expect(list().classList.contains("hidden")).toBe(false)
  })

  it("filters options based on input text", () => {
    input().value = "alice"
    input().dispatchEvent(new Event("input"))

    expect(options()[0].classList.contains("hidden")).toBe(false)
    expect(options()[1].classList.contains("hidden")).toBe(true)
    expect(options()[2].classList.contains("hidden")).toBe(true)
  })

  it("shows all options when input is empty", () => {
    input().value = ""
    input().dispatchEvent(new Event("input"))

    options().forEach(option => {
      expect(option.classList.contains("hidden")).toBe(false)
    })
  })

  it("selects option and sets both input and hidden values", () => {
    options()[1].click()

    expect(input().value).toBe("bob@example.com")
    expect(hidden().value).toBe("bob@example.com")
  })

  it("closes list after selecting option", () => {
    input().dispatchEvent(new Event("focus"))
    expect(list().classList.contains("hidden")).toBe(false)

    options()[0].click()
    expect(list().classList.contains("hidden")).toBe(true)
  })

  it("closes list when clicking outside", () => {
    input().dispatchEvent(new Event("focus"))
    expect(list().classList.contains("hidden")).toBe(false)

    document.body.click()
    expect(list().classList.contains("hidden")).toBe(true)
  })

  it("commits freeform input value to hidden field on change", () => {
    input().value = "custom@example.com"
    input().dispatchEvent(new Event("change"))

    expect(hidden().value).toBe("custom@example.com")
  })
})
