var jQuery = require("jquery")
window.$ = window.jQuery = jQuery

require("@hotwired/turbo-rails")
require("bootstrap")
require("./vendor/bootstrap-combobox")
require("./setup")
require("./bootstrap_setup")

import { Application } from "@hotwired/stimulus"
import TestApiController from "./controllers/test_api_controller"

const application = Application.start()
application.register("test-api", TestApiController)
