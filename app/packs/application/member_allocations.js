document.addEventListener("turbolinks:load", () => {
  $('#teamMemberNew').on('show.bs.modal', (event) => {
    var button = $(event.relatedTarget) // Button that triggered the modal
    var member_id = button.data('member-id')
    var member_name = button.data('member-name')
    var team_member_id = button.data('team-member-id')

    var modal = $('#teamMemberNew')
    if (!!team_member_id) {
     modal.find('.modal-title').text('Verplaats ' + member_name + ' naar team:')
    } else {
     modal.find('.modal-title').text('Voeg ' + member_name + ' toe aan team:')
    }
    modal.find('.modal-body #team_member_member_id').val(member_id)
    modal.find('.modal-body #team_member_id').val(team_member_id)
  }).on('shown.bs.modal', (event) => {
    $('#teamMemberNew input[type=submit]').focus();
  })
})
