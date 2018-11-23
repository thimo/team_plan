import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    $(this.element).stickyTableHeaders({fixedOffset: $('.app-header')});
    $(this.element).addClass('table-sticky-header')
  }

  disconnect() {
    $(this.element).stickyTableHeaders('destroy');
  }
}
