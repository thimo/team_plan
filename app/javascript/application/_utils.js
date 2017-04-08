// Create Turbolinks unload event
const dispatchUnloadEvent = function() {
  const event = document.createEvent("Events")
  event.initEvent("turbolinks:unload", true, false)
  document.dispatchEvent(event)
}
addEventListener("beforeunload", dispatchUnloadEvent)
addEventListener("turbolinks:before-render", dispatchUnloadEvent)

$(document).on('turbolinks:load', function() {
  // Auto-size all textarea's
  $('textarea').autosize();

  if ($('.has-error').length > 0) {
    // Set focus on first field with an error
    const fieldTypes = '.has-error input[type=text], .has-error input[type=email], .has-error input[type=number], .has-error textarea';
    $(fieldTypes).first().focus().select();
  } else {
    // Set focus on first input field
    const fieldTypes = 'form input[type=text], form input[type=email], form input[type=number]';
    $(fieldTypes).filter('[data-provide!=datepicker]').first().focus().select();
  }

  // Make rows clickable
  $('table.tr-links > tbody > tr').each((index, tr) => {
    const links = $(tr).find('a')
    if (links.length > 0) {
      $(tr).on('click', function(event) {
        // Only execute if clicked on anything else in table row
        if (!$.inArray(event.target.tagName.toLowerCase(), ['a', 'i', 'button', 'input'])) {
          document.location = links[0].href;
        }
      });
      $(tr).addClass('clickable');
    }
  });

  $('.no-touch [title]').tooltip();

  // Restore scroll position
  const scrollPosition = $("[data-scroll-position]").data("scrollPosition")
  if (!!scrollPosition && !!localStorage.getItem(scrollPosition)) {
    $(window).scrollTop(localStorage.getItem(scrollPosition));
  }
});

$(document).on('turbolinks:unload', function() {
  // Store scroll position for pages with data-scroll-position
  const scrollPosition = $("[data-scroll-position]").data("scrollPosition")
  if (!!scrollPosition) {
    localStorage.setItem(scrollPosition, $(window).scrollTop());
  }
});
