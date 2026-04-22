require("@hotwired/turbo-rails")
require("./setup")

import { Application } from "@hotwired/stimulus"
import TestApiController from "./controllers/test_api_controller"
import ComboboxController from "./controllers/combobox_controller"

const application = Application.start()
application.register("test-api", TestApiController)
application.register("combobox", ComboboxController)
