$(document).on('turbolinks:load', function() {
  var fieldTypes;
  var fieldTypes;
  $('textarea').autosize();
  if ($('.has-error').length > 0) {
    fieldTypes = '.has-error input[type=text], .has-error input[type=email], .has-error input[type=number], .has-error textarea';
    $(fieldTypes).first().focus().select();
  } else {
    fieldTypes = 'form input[type=text], form input[type=email], form input[type=number], form textarea';
    $(fieldTypes).filter('[data-provide!=datepicker]').first().focus().select();
  }
  $('table.tr-links > tbody > tr').each(function() {
    if ($(this).find('a').length > 0) {
      $(this).on('click', function() {
        document.location = $(this).find('a')[0].href;
      });
      $(this).addClass('clickable');
    }
  });
  return $('.no-touch [title]').tooltip();
});

var dispatchUnloadEvent = function() {
  var event = document.createEvent("Events")
  event.initEvent("turbolinks:unload", true, false)
  document.dispatchEvent(event)
}

addEventListener("beforeunload", dispatchUnloadEvent)
addEventListener("turbolinks:before-render", dispatchUnloadEvent)
