$(document).on('turbolinks:load', function() {
  $('#team_member_member_id').select2({
    placeholder: "Selecteer lid",
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
    }
  });
});
