$(document).on('turbolinks:load', function() {
  $('form[data-behavior="autosave"]').each((index, form) => {
    autosaveForm(form)
  });
});

window.autosaveForm = function(form) {
  $(form).find('input[type=checkbox]').on('change', (e) => {
    $(form).submit()
  })
}
