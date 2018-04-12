document.addEventListener("turbolinks:load", () => {
  $('form[data-behavior="autosave"]').each((index, form) => {
    autosaveForm(form)
  });

  $('.presences-toggle').on('click', function() {
    var target_id = $(this).data('target-id')
    var target = $('#' + target_id)
    if (target.is(':visible')) {
      target.closest('tr').hide()
    } else {
      target.closest('tr').show()

      $.ajax({
        dataType: 'script',
        type: "GET",
        url: $(this).data('content-url')
      }).done(function(data) {
      })
    }
  })
});

var autosaveForm = function(form) {
  $(form).find('input[type=checkbox], input[type=radio], textarea, select').on('change', (e) => {
    $(form).submit()
  })
}
window.autosaveForm = autosaveForm
