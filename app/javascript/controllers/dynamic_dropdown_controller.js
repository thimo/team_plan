import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "button", "dropdown" ]

  connect() {}

  disconnect() {}

  loadContent(e) {
    $.ajax({
      url: this.data.get('url'),
      dataType: 'json'
    }).done((data) => {
      this.dropdownTarget.innerHTML = data.html
      this.buttonTarget.innerHTML = data.presence_count
    });
  }
}
