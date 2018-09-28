import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    $(this.element).select2({
      matcher: function(params, data) {
        var i, terms;
        if (!params.term) {
          return data;
        }
        terms = params.term.split(' ');
        i = 0;
        while (i < terms.length) {
          if (!!terms[i]) {
            if (data.text.toUpperCase().indexOf(terms[i].toUpperCase()) < 0) {
              return null;
            }
          }
          i++;
        }
        return data;
      },
      width: null,       // Prevent select2 calculating width
      theme: "bootstrap" // In case the select2 is initialized before the default theme is set
    });
  }

  disconnect() {
  }
}
