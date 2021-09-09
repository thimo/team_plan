import { Controller } from "stimulus"

export default class extends Controller {
  connect() {}

  disconnect() {}

  toggle() {
    document.body.classList.toggle(this.data.get('class'))
  }
}
