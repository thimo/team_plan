function setEvaluationClass(target) {
  $(target).removeClass('select-primary').removeClass('select-success').removeClass('select-secondary').removeClass('select-warning').removeClass('select-danger')

  if (!!target.value) {
    $(target).removeClass('form-control-error')

    applyClassForRating(target, target.value)
  }
}

function applyClassForRating(target, rating) {
  switch (rating) {
    case '10':
    case '9':
      $(target).addClass('select-primary')
      break;
    case '8':
      $(target).addClass('select-success')
      break;
    case '7':
    case '6':
      $(target).addClass('select-secondary')
      break;
    case '5':
      $(target).addClass('select-warning')
      break;
    case '4':
    case '3':
    case '2':
    case '1':
      $(target).addClass('select-danger')
      break;
  }
}

document.addEventListener("turbolinks:load", () => {
  $('.evaluation select.evaluation-rating').each((index, target) => {
    setEvaluationClass(target)
  })
  $('.evaluation div.evaluation-rating[data-evaluation-value]').each((index, target) => {
    applyClassForRating(target, target.dataset.evaluationValue)
  })
  $('.evaluation select.evaluation-rating').on('change', (e) => {
    setEvaluationClass(e.target)
  })

  $('select.field_positions').each((index, target) => {
    $(target).select2({
      theme: "bootstrap",
      placeholder: "Veldpositie"
    });
  })
})
