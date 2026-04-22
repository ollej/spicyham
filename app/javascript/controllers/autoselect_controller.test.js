/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import AutoselectController from "./autoselect_controller"

const HTML = `
<input type="text" value="hello world" data-controller="autoselect">
`

let application

function input() { return document.querySelector("input") }

beforeEach(async () => {
  document.body.innerHTML = HTML
  application = Application.start()
  application.register("autoselect", AutoselectController)
  await new Promise(resolve => setTimeout(resolve, 0))
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("AutoselectController", () => {
  it("selects all text on connect", () => {
    expect(input().selectionStart).toBe(0)
    expect(input().selectionEnd).toBe("hello world".length)
  })

  it("selects nothing for empty input", async () => {
    document.body.innerHTML = '<input type="text" value="" data-controller="autoselect">'
    await new Promise(resolve => setTimeout(resolve, 0))
    expect(input().selectionStart).toBe(0)
    expect(input().selectionEnd).toBe(0)
  })
})
