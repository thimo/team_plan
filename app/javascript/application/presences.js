$(document).on('turbolinks:load', function() {
  $('form[data-behavior="autosave"]').each((index, form) => {
    autosaveForm(form)
  });
});

var autosaveForm = function(form) {
  $(form).find('input[type=checkbox], input[type=radio], textarea, select').on('change', (e) => {
    $(form).submit()
  })
}
window.autosaveForm = autosaveForm

$(function () {
  $('.presence-popover').popover({
    html: true,
    placement: 'bottom'
  }).on('show.bs.popover', function () {
    $.ajax({
      dataType: 'script',
      type: "GET",
      url: $(this).data('popover-content-url')
    }).done(function(data) {
    })
  });
})
