$(document).on('turbolinks:load', () => {
  $('.google-maps-iframe-link').on('click', function() {
    let url = $(this).data('googleMapsUrl')
    $('#google-maps').attr('src', url);
    $('.google-maps-iframe-link').removeClass('active')
    $(this).addClass('active')
    return false;
  })
})
