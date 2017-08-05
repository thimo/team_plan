$(document).on('turbolinks:load', function() {
  $('form[data-behavior="autosave"]').each((index, form) => {
    autosaveForm(form)
  });
});
