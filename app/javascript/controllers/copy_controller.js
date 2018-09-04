import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "input", "button" ]

  connect() {}

  disconnect() {}

  copyToBuffer() {
    this.inputTarget.select()
    document.execCommand("copy");
    this.buttonTarget.innerHTML = "Gekopieerd"
  }
}
