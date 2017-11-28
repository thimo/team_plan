$(document).on('turbolinks:load', function() {
  $('#team_evaluation_bulk_updates .team-select-toggle').change(function() {
    var checkedValue = this.checked;
    $('input.team-select').each(function(index) {
      this.checked = checkedValue
    })
  })
});

$(document).on('turbolinks:before-cache', () => {
})
