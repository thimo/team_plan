import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    $(this.element).select2({
      allowClear: true,
      width: null,       // Prevent select2 calculating width
      theme: "bootstrap" // In case the select2 is initialized before the default theme is set
    });
  }

  disconnect() {}
}
