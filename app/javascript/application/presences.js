$(document).on('turbolinks:load', function() {
  $('form[data-behavior="autosave"]').each((index, form) => {
    autosaveForm(form)
  });

  $('.presence-popover').popover({
    title: $('<a onclick="closePopovers()" class="d-block"><i class="fa fa-times float-right pl-2" />Aanwezig</a>'),
    html: true,
    placement: 'bottom'
  }).on('show.bs.popover', function () {
    closePopovers()
    $.ajax({
      dataType: 'script',
      type: "GET",
      url: $(this).data('popover-content-url')
    }).done(function(data) {
      $('.presence-popover').popover('update')
    })
  });
});

var autosaveForm = function(form) {
  $(form).find('input[type=checkbox], input[type=radio], textarea, select').on('change', (e) => {
    $(form).submit()
  })
}
window.autosaveForm = autosaveForm

var closePopovers = function() {
  $('.presence-popover').popover('hide')
}
window.closePopovers = closePopovers
