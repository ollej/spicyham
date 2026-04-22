/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"
import { Application } from "@hotwired/stimulus"
import ConfirmDialogController from "./confirm_dialog_controller"

const HTML = `
<div data-controller="confirm-dialog">
  <button data-action="click->confirm-dialog#open" data-label="test@example.com" data-destinations="fwd@example.com" data-url="/emails/test">Delete</button>
  <button data-action="click->confirm-dialog#open" data-label="other@example.com" data-destinations="a@b.com and c@d.com" data-url="/emails/other">Delete other</button>
  <dialog data-confirm-dialog-target="dialog">
    <p data-confirm-dialog-target="message"></p>
    <p data-confirm-dialog-target="destinations"></p>
    <form data-confirm-dialog-target="form" method="post">
      <button type="submit">Confirm</button>
    </form>
    <button data-action="click->confirm-dialog#cancel">Cancel</button>
  </dialog>
</div>
`

let application

function dialog() { return document.querySelector("dialog") }
function message() { return document.querySelector('[data-confirm-dialog-target="message"]') }
function destinations() { return document.querySelector('[data-confirm-dialog-target="destinations"]') }
function form() { return document.querySelector('[data-confirm-dialog-target="form"]') }
function buttons() { return document.querySelectorAll('[data-action="click->confirm-dialog#open"]') }
function cancelButton() { return document.querySelector('[data-action="click->confirm-dialog#cancel"]') }

beforeEach(async () => {
  document.body.innerHTML = HTML
  dialog().showModal = vi.fn(function() { this.open = true })
  dialog().close = vi.fn(function() { this.open = false })
  application = Application.start()
  application.register("confirm-dialog", ConfirmDialogController)
  await new Promise(resolve => setTimeout(resolve, 0))
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("ConfirmDialogController", () => {
  it("opens dialog with email label, destinations, and URL", () => {
    buttons()[0].click()
    expect(dialog().showModal).toHaveBeenCalled()
    expect(message().textContent).toBe("test@example.com")
    expect(destinations().textContent).toBe("fwd@example.com")
    expect(form().action).toContain("/emails/test")
  })

  it("updates dialog for different email", () => {
    buttons()[1].click()
    expect(message().textContent).toBe("other@example.com")
    expect(destinations().textContent).toBe("a@b.com and c@d.com")
    expect(form().action).toContain("/emails/other")
  })

  it("closes dialog on cancel", () => {
    buttons()[0].click()
    expect(dialog().open).toBe(true)

    cancelButton().click()
    expect(dialog().close).toHaveBeenCalled()
    expect(dialog().open).toBe(false)
  })

  it("starts with dialog closed", () => {
    expect(dialog().open).toBeFalsy()
  })
})
