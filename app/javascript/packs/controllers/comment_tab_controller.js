import { Controller } from "stimulus"

export default class extends Controller {
  connect() {}

  activateTab(event) {
    $.ajax({
      dataType: 'script',
      type: "POST",
      url: this.element.dataset.setActiveTabUrl,
      data: { tab: this.element.dataset.tab }
    })
  }
}
