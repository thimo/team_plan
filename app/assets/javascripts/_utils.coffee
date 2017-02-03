$ ->
  `var fieldTypes`
  $('textarea').autosize()
  if $('.has-error').length > 0
    fieldTypes = '.has-error input[type=text], .has-error input[type=email], .has-error input[type=number], .has-error textarea'
    $(fieldTypes).first().focus().select()
  else
    fieldTypes = 'form input[type=text], form input[type=email], form input[type=number], form textarea'
    $(fieldTypes).filter('[data-provide!=datepicker]').first().focus().select()
  return

$ ->
  $('table.tr-links > tbody > tr').each ->
    if $(this).find('a').length > 0
      $(this).on 'click', ->
        document.location = $(this).find('a')[0].href
        return
      $(this).addClass 'clickable'
    return
