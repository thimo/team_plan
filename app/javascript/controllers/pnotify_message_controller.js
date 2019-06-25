import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    PNotify.alert({
      type: this.data.get("type"),
      text: this.data.get("text"),
      delay: this.data.get("delay")
    })
  }
}
