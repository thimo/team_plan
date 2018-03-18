document.addEventListener("turbolinks:load", () => {
  // Auto-size all textarea's
  autosize($('textarea'));
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    autosize.update($('textarea'))
  })

  // Initialize date pickers
  $('[data-provide="datepicker"]').datepicker();

  if ($('.has-error').length > 0) {
    // Set focus on first field with an error
    const fieldTypes = '.has-error input[type=text], .has-error input[type=email], .has-error input[type=number], .has-error textarea';
    $(fieldTypes).first().focus().select();
  }

  // Make rows clickable
  $('table.tr-links > tbody > tr').each((index, tr) => {
    const links = $(tr).find('a[href]')
    if (links.length > 0) {
      $(tr).on('click', function(event) {
        // Only execute if clicked on anything else in table row
        if ($.inArray(event.target.tagName.toLowerCase(), ['a', 'i', 'button', 'input', 'path']) < 0) {
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

  new LazyLoad();
});

document.addEventListener("turbolinks:before-cache", () => {
  $('select.field_positions').each((index, target) => {
    $(target).select2('destroy');
  })
  $('.no-touch [title]').tooltip('dispose');
})

document.addEventListener("turbolinks:before-render", function(event) {
  if (typeof FontAwesome !== 'undefined') {
    FontAwesome.dom.i2svg({
      node: event.data.newBody
    });
  }
});

const stack_topright = {
  "dir1": "down",
  "dir2": "left",
  "firstpos1": 10,
  "firstpos2": 10,
  "spacing1": 10,
  "spacing2": 10
};

PNotify.defaults.styling = "bootstrap3";
PNotify.defaults.icons = "fontawesome5";
PNotify.defaults.shadow = false;
PNotify.defaults.cornerClass = "alert-fill";
PNotify.defaults.stack = stack_topright;
