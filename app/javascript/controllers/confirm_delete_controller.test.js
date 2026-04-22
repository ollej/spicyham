/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"
import { Application } from "@hotwired/stimulus"
import ConfirmDeleteController from "./confirm_delete_controller"

const HTML = `
<div data-controller="confirm-delete" data-confirm-delete-phrase-value="DELETE">
  <button data-action="click->confirm-delete#reveal">Cancel my account</button>
  <dialog data-confirm-delete-target="dialog">
    <input type="text" data-confirm-delete-target="input" data-action="input->confirm-delete#verify">
    <button data-confirm-delete-target="submit" disabled>Confirm deletion</button>
    <button data-action="click->confirm-delete#cancel">Cancel</button>
  </dialog>
</div>
`

let application

function dialog() { return document.querySelector("dialog") }
function input() { return document.querySelector('[data-confirm-delete-target="input"]') }
function submit() { return document.querySelector('[data-confirm-delete-target="submit"]') }
function revealButton() { return document.querySelector('[data-action="click->confirm-delete#reveal"]') }
function cancelButton() { return document.querySelector('[data-action="click->confirm-delete#cancel"]') }

beforeEach(async () => {
  document.body.innerHTML = HTML
  // jsdom doesn't implement showModal/close natively, so stub them
  dialog().showModal = vi.fn(function() { this.open = true })
  dialog().close = vi.fn(function() { this.open = false })
  application = Application.start()
  application.register("confirm-delete", ConfirmDeleteController)
  await new Promise(resolve => setTimeout(resolve, 0))
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("ConfirmDeleteController", () => {
  it("starts with dialog closed and submit disabled", () => {
    expect(dialog().open).toBeFalsy()
    expect(submit().disabled).toBe(true)
  })

  it("opens dialog on reveal click", () => {
    revealButton().click()
    expect(dialog().showModal).toHaveBeenCalled()
    expect(dialog().open).toBe(true)
  })

  it("clears input when revealing dialog", () => {
    input().value = "leftover"
    revealButton().click()
    expect(input().value).toBe("")
  })

  it("keeps submit disabled when input does not match phrase", () => {
    revealButton().click()
    input().value = "DELE"
    input().dispatchEvent(new Event("input"))
    expect(submit().disabled).toBe(true)
  })

  it("enables submit when input matches phrase exactly", () => {
    revealButton().click()
    input().value = "DELETE"
    input().dispatchEvent(new Event("input"))
    expect(submit().disabled).toBe(false)
  })

  it("disables submit again when input changes away from phrase", () => {
    revealButton().click()
    input().value = "DELETE"
    input().dispatchEvent(new Event("input"))
    expect(submit().disabled).toBe(false)

    input().value = "DELETE "
    input().dispatchEvent(new Event("input"))
    expect(submit().disabled).toBe(true)
  })

  it("closes dialog on cancel click", () => {
    revealButton().click()
    expect(dialog().open).toBe(true)

    cancelButton().click()
    expect(dialog().close).toHaveBeenCalled()
    expect(dialog().open).toBe(false)
  })
})
