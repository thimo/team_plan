$(document).on('turbolinks:load', function() {
  $('#team_member_players, #team_member_coaches, #team_member_trainers, #team_member_team_parents').select2({
    placeholder: "Selecteer leden",
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

$(document).on('turbolinks:before-cache', () => {
  $('#team_member_players, #team_member_coaches, #team_member_trainers, #team_member_team_parents').select2('destroy');
})

var matchParts = function(term, text) {
  if (text.toUpperCase().indexOf(term.toUpperCase()) === 0) {
    return true;
  }
  return false;
};
