$(document).on('turbolinks:load', function() {
  $('form[data-behavior="autosave"]').each((index, form) => {
    autosaveForm(form)
  });
});

var autosaveForm = function(form) {
  $(form).find('input[type=checkbox], input[type=radio], textarea').on('change', (e) => {
    $(form).submit()
  })
}
window.autosaveForm = autosaveForm
