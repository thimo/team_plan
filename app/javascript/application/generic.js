import autosize from 'autosize'
window.autosize = autosize
import LazyLoad from 'vanilla-lazyload'

document.addEventListener("turbolinks:load", () => {
  // $('.sidebar').sidebar();
  // $('.aside-menu')['aside-menu']();

  // Auto-size all textarea's
  autosize($('textarea'));
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    autosize.update($('textarea'))
  })
  // After initial page load, textarea's no longer properly size. This 'fixes' it.
  // Behaviour difference can be seen between Cmd-Shift-R and Cmd-R reloads
  setTimeout(function() { autosize.update(document.querySelectorAll('textarea')); }, 50)

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

  new LazyLoad();

  $('.custom-file-input').on('change', function() {
    let fileName = $(this).val().split('\\').pop();
    $(this).next('.custom-file-label').addClass("selected").html(fileName);
  });
});

document.addEventListener("turbolinks:before-cache", () => {
  $('.no-touch [title]').tooltip('dispose');
  $('.select2-hidden-accessible').select2('destroy');
  $('body').removeClass('sidebar-show');
})

document.addEventListener("turbolinks:before-render", (event) => {
  if (typeof FontAwesome !== 'undefined') {
    FontAwesome.dom.i2svg({
      node: event.data.newBody
    });
  }
});
