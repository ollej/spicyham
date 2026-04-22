/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"
import { Application } from "@hotwired/stimulus"
import TestApiController from "./test_api_controller"

const HTML = `
<form data-controller="test-api" data-test-api-url-value="/test_api.json">
  <select data-test-api-target="api" data-action="change->test-api#reset"><option value="gandiv5">Gandi v5</option></select>
  <input data-test-api-target="apiKey" value="test-key" data-action="change->test-api#reset">
  <input data-test-api-target="apiUser" value="test-user" data-action="change->test-api#reset">
  <input data-test-api-target="domain" value="example.com" data-action="change->test-api#reset">
  <a href="#" class="border-gray-600 text-gray-300 test-api-btn" data-test-api-target="button" data-action="click->test-api#test">
    <span data-test-api-target="processing" class="hidden"></span>
    <span data-test-api-target="success" class="hidden"></span>
    <span data-test-api-target="failed" class="hidden"></span>
    <span data-test-api-target="untested"></span>
    Test API
  </a>
</form>
`

let application
let button

function findTarget(name) {
  return document.querySelector(`[data-test-api-target="${name}"]`)
}

beforeEach(async () => {
  document.body.innerHTML = HTML
  application = Application.start()
  application.register("test-api", TestApiController)
  await new Promise(resolve => setTimeout(resolve, 0))
  button = findTarget("button")
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

describe("TestApiController", () => {
  it("sends POST fetch to the configured URL", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true })
    vi.stubGlobal("fetch", fetchMock)

    button.click()
    await vi.waitFor(() => expect(fetchMock).toHaveBeenCalled())

    expect(fetchMock).toHaveBeenCalledWith("/test_api.json", expect.objectContaining({
      method: "POST",
    }))
  })

  it("sends form field values in the request body", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true })
    vi.stubGlobal("fetch", fetchMock)

    button.click()
    await vi.waitFor(() => expect(fetchMock).toHaveBeenCalled())

    const body = fetchMock.mock.calls[0][1].body.toString()
    expect(body).toContain("api=gandiv5")
    expect(body).toContain("api_key=test-key")
    expect(body).toContain("api_user=test-user")
    expect(body).toContain("domain=example.com")
  })

  it("shows success state on 2xx response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true }))

    button.click()
    await vi.waitFor(() => expect(button.classList.contains("border-green-600")).toBe(true))

    expect(findTarget("success").classList.contains("hidden")).toBe(false)
    expect(findTarget("untested").classList.contains("hidden")).toBe(true)
  })

  it("shows fail state on 4xx response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false }))

    button.click()
    await vi.waitFor(() => expect(button.classList.contains("border-red-600")).toBe(true))

    expect(findTarget("failed").classList.contains("hidden")).toBe(false)
    expect(findTarget("untested").classList.contains("hidden")).toBe(true)
  })

  it("shows fail state on network error", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Network error")))

    button.click()
    await vi.waitFor(() => expect(button.classList.contains("border-red-600")).toBe(true))

    expect(findTarget("failed").classList.contains("hidden")).toBe(false)
  })

  it("shows processing state during request", async () => {
    let resolveRequest
    vi.stubGlobal("fetch", vi.fn().mockImplementation(() => new Promise(r => { resolveRequest = r })))

    button.click()
    await vi.waitFor(() => expect(findTarget("processing").classList.contains("hidden")).toBe(false))

    expect(findTarget("untested").classList.contains("hidden")).toBe(true)

    resolveRequest({ ok: true })
  })

  it("reset restores default state", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true }))
    button.click()
    await vi.waitFor(() => expect(button.classList.contains("border-green-600")).toBe(true))

    findTarget("api").dispatchEvent(new Event("change"))
    await vi.waitFor(() => expect(button.classList.contains("border-gray-600")).toBe(true))

    expect(button.classList.contains("border-green-600")).toBe(false)
    expect(findTarget("untested").classList.contains("hidden")).toBe(false)
    expect(findTarget("success").classList.contains("hidden")).toBe(true)
  })
})
