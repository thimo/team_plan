import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "iframe", "link" ]

  activateIframe(event) {
    event.preventDefault()

    let url = event.target.dataset.googleMapsUrl
    this.iframeTarget.src = url
    this.linkTargets.forEach((el, i) => {
      el.classList.toggle("active", el == event.target)
    })
  }
}
