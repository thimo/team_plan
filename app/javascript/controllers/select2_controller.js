import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    $(this.element).select2({
      allowClear: true,
      theme: "bootstrap"
    });
  }

  disconnect() {}
}
