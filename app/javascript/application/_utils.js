// Create Turbolinks unload event
var dispatchUnloadEvent = function() {
  var event = document.createEvent("Events")
  event.initEvent("turbolinks:unload", true, false)
  document.dispatchEvent(event)
}
addEventListener("beforeunload", dispatchUnloadEvent)
addEventListener("turbolinks:before-render", dispatchUnloadEvent)

$(document).on('turbolinks:load', function() {
  var fieldTypes;
  $('textarea').autosize();
  if ($('.has-error').length > 0) {
    fieldTypes = '.has-error input[type=text], .has-error input[type=email], .has-error input[type=number], .has-error textarea';
    $(fieldTypes).first().focus().select();
  } else {
    // fieldTypes = 'form input[type=text], form input[type=email], form input[type=number], form textarea';
    fieldTypes = 'form input[type=text], form input[type=email], form input[type=number]';
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

  $('.no-touch [title]').tooltip();

  // Restore scroll position
  var scrollPosition = $("[data-scroll-position]").data("scrollPosition")
  if (!!scrollPosition && !!localStorage.getItem(scrollPosition)) {
    $(window).scrollTop(localStorage.getItem(scrollPosition));
  }
});

$(document).on('turbolinks:unload', function() {
  // Store scroll position for pages with data-scroll-position
  var scrollPosition = $("[data-scroll-position]").data("scrollPosition")
  if (!!scrollPosition) {
    localStorage.setItem(scrollPosition, $(window).scrollTop());
  }
});
