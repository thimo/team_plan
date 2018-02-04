import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "iframe" ]

  activateIframe(event) {
    event.preventDefault()

    let url = event.target.dataset.googleMapsUrl
    this.iframeTarget.src = url
    $('.google-maps-iframe-link').removeClass('active')
    event.target.classList.add('active')
  }
}
