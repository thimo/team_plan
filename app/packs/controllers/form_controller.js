// Helper for dirty checks on a form
// TODO: This controller probably holds too much functionality as it was copied from another project

import { Controller } from "stimulus"
import bsCustomFileInput from 'bs-custom-file-input'

export default class extends Controller {
  static targets = [ "form", "submit", "field" ]
  fields = null;
  changedClass = "field-changed"

  connect() {
    this.reset()
    this.bindFields()
    this.addEventListeners()
    bsCustomFileInput.init()

    autosize(this.element.querySelectorAll('textarea'));
    // After initial page load, textarea's no longer properly size. This 'fixes' it.
    // Behaviour difference can be seen between Cmd-Shift-R and Cmd-R reloads
    setTimeout(() => { autosize.update(this.element.querySelectorAll('textarea')); }, 50)
  }

  disconnect() {
    this.removeEventListeners()
    bsCustomFileInput.destroy()
  }

  submit() {
    this.submitTarget.click()
  }

  isDirty() {
    // Disable dirty checks for now
    return false;

    if (this.fields == null) { return false }

    var fieldHash = this.formFieldHash();
    for (var key in fieldHash) {
      if (this.fields[key] !== fieldHash[key]) {
        return true;
      }
    }

    return false;
  }

  formFieldHash() {
    var result = {};
    $.each($(this.formTarget).find(":input").serializeArray(), function() {
      result[this.name] = this.value;
    });
    return result;
  }

  reset() {
    this.fields = this.formFieldHash();
  }

  refresh() {
    $(this.formTarget).find("#refresh_only").val("1")
    storeScrollPosition()
    this.submit()
  }

  reload() {
    $(this.formTarget).find("#reload_data").val("1")
    storeScrollPosition()
    this.submit()
  }

  confirmCloseMessage() {
    return $(this.formTarget).data('confirmClose')
  }

  confirmSaveMessage() {
    return $(this.formTarget).data('confirmSave')
  }

  addEventListeners() {
    addEventListener("beforeunload", this, false);
    addEventListener("turbolinks:before-visit", this, false)
    addEventListener(`form:${this.formTarget.id}:formLoaded`, this, false)

    $(this.element).parents(".modal").off('hide.bs.modal').on('hide.bs.modal', $.proxy(this.hideModal, this));
  }

  removeEventListeners() {
    removeEventListener("beforeunload", this, false);
    removeEventListener("turbolinks:before-visit", this, false)
    removeEventListener(`form:${this.formTarget.id}:formLoaded`, this, false)
  }

  hideModal(e) {
    if (e.namespace === 'bs.modal') {
      if (this.isDirty()) {
        if (confirm(this.confirmCloseMessage())) {
          this.reset()
        } else {
          e.preventDefault()
        }
      }
    }
  }

  bindFields() {
    this.fieldTargets.forEach((field) => {
      field.addEventListener("change", this, false);
    })
  }

  markChangedFields() {
    this.fieldTargets.forEach((field) => {
      this.fieldChanged(field)
    })
  }

  fieldChanged(field) {
    if ($(this.formTarget).data('markChangedFields') && (this.fields[field.name] != field.value)) {
      $(field).parents(".form-group").addClass(this.changedClass)
    } else {
      $(field).parents(".form-group").removeClass(this.changedClass)
    }
  }

  showLockVersionMessage() {
    if (!$(this.formTarget).data('lockVersionsValidationError')) {
      return
    }

    var notice = PNotify.notice({
      title: "Data is aangepast",
      text: "De data is sinds het openen van het formulier aangepast. Wil je de data opnieuw laden?",
      textTrusted: true,
      icon: 'fa fa-question-circle',
      hide: false,
      addClass: 'pnotify-alert-white',
      stack: {
        'modal': true,
      },
      that: this,
      modules: {
        Confirm: {
          confirm: true,
          buttons: [{
            text: 'Sluiten',
            click: function(notice) {
              notice.close();
            }
          },
          {
            text: 'Opnieuw laden',
            primary: true,
            click: function(notice) {
              this.reload();
            }.bind(this)
          }]
        },
        Buttons: {
          closer: true,
          sticker: false
        },
        History: {
          history: false
        }
      }
    });
  }

  handleEvent(e) {
    switch(e.type) {
      case 'beforeunload':
        if (this.isDirty()) {
          var confirmationMessage = this.confirmCloseMessage();

          (e || window.event).returnValue = confirmationMessage;     //Gecko + IE
          return confirmationMessage;                                //Webkit, Safari, Chrome etc.
        }
        break;
      case 'turbolinks:before-visit':
        if (this.isDirty()) {
          if (!confirm(this.confirmCloseMessage())) {
            e.preventDefault()
          }
        }
        break;
      case `form:${this.formTarget.id}:formLoaded`:
        this.bindFields()
        this.markChangedFields()
        this.showLockVersionMessage()
        break;
      case 'change':
        this.fieldChanged(e.target)
        break;
    }
  }
}
