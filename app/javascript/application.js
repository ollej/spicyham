require("@hotwired/turbo-rails")

import { Application } from "@hotwired/stimulus"
import AlertController from "./controllers/alert_controller"
import AutoselectController from "./controllers/autoselect_controller"
import ClipboardController from "./controllers/clipboard_controller"
import ComboboxController from "./controllers/combobox_controller"
import ConfirmDeleteController from "./controllers/confirm_delete_controller"
import ConfirmDialogController from "./controllers/confirm_dialog_controller"
import DropdownController from "./controllers/dropdown_controller"
import TestApiController from "./controllers/test_api_controller"
import ToggleController from "./controllers/toggle_controller"

const application = Application.start()
application.register("alert", AlertController)
application.register("autoselect", AutoselectController)
application.register("clipboard", ClipboardController)
application.register("combobox", ComboboxController)
application.register("confirm-delete", ConfirmDeleteController)
application.register("confirm-dialog", ConfirmDialogController)
application.register("dropdown", DropdownController)
application.register("test-api", TestApiController)
application.register("toggle", ToggleController)
