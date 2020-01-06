import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ 'icon', 'content' ]

  connect() {
    if (!this.hasIconTarget) {
      return;
    }

    if (this.data.get('startCollapsed') == 'true') {
      this.collapse();
    } else {
      this.expand();
    }
  }

  toggle() {
    if (this.iconTarget.classList.contains(this.expandIcon())) {
      this.expand()
    } else {
      this.collapse()
    }
  }

  expand() {
    this.iconTarget.classList.remove(this.expandIcon())
    this.iconTarget.classList.add(this.collapseIcon())

    this.contentTargets.forEach(el => {
      el.classList.remove('d-none')
    });
  }

  collapse() {
    this.iconTarget.classList.remove(this.collapseIcon())
    this.iconTarget.classList.add(this.expandIcon())

    this.contentTargets.forEach(el => {
      el.classList.add('d-none')
    });
  }

  collapseIcon() {
    return this.data.get('collapseIcon')
  }

  expandIcon() {
    return this.data.get('expandIcon')
  }
}
