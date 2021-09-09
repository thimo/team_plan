import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    // ARRGGHHHH!! Ugly solution to display alert with a fade-in
    setTimeout(() => { $(this.element).removeClass('invisible').addClass('show fade') }, 250)
  }

  disconnect() {}
}
