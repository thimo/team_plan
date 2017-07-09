$(document).on('turbolinks:load', () => {
  // Auto-size all textarea's
  $('textarea').autosize();

  // Initialize date pickers
  $('[data-provide="datepicker"]').datepicker();

  if ($('.has-error').length > 0) {
    // Set focus on first field with an error
    const fieldTypes = '.has-error input[type=text], .has-error input[type=email], .has-error input[type=number], .has-error textarea';
    $(fieldTypes).first().focus().select();
  } else {
    // Set focus on first input field
    const fieldTypes = 'form input[type=text], form input[type=email], form input[type=number], form textarea';
    $(fieldTypes).not('header input').first().focus().select();
  }

  // Make rows clickable
  $('table.tr-links > tbody > tr').each((index, tr) => {
    const links = $(tr).find('a')
    if (links.length > 0) {
      $(tr).on('click', function(event) {
        // Only execute if clicked on anything else in table row
        if ($.inArray(event.target.tagName.toLowerCase(), ['a', 'i', 'button', 'input']) < 0) {
          document.location = links[0].href;
        }
      });
      $(tr).addClass('clickable');
    }
  });

  $('.no-touch [title]').tooltip();

  $('select.field_positions').each((index, target) => {
    $(target).select2({placeholder: "Veldpositie"});
  })
});

$(document).on('turbolinks:before-cache', () => {
  $('select.field_positions').each((index, target) => {
    $(target).select2('destroy');
  })
})
