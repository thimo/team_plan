document.addEventListener("turbolinks:load", () => {
  $('#team_evaluation_bulk_updates .team-select-toggle').change(function() {
    var checkedValue = this.checked;
    $('input.team-select').each(function(index) {
      this.checked = checkedValue
    })
  })
});

document.addEventListener("turbolinks:before-cache", () => {
})
