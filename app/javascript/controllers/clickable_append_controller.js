// Convert a input field's append span into a <label> so the focus is placed on the input when the
// user clicks the append span (an icon or text)

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "input", "span" ]

  connect() {
    if (this.spanTarget.parentElement && this.inputTarget.id) {
      $(this.spanTarget.parentElement).attr('for', this.inputTarget.id).changeElementType('label')
    }
  }

  disconnect() {
  }
}
