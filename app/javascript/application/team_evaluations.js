function setEvaluationClass(target) {
  let evaluationClass = 'custom-select evaluation-rating'
  if (!!target.value) {
    switch (target.value) {
      case '10':
      case '9':
      case '8':
        evaluationClass += ' btn btn-success'
        break;
      case '7':
      case '6':
        evaluationClass += ' btn'
        break;
      case '5':
        evaluationClass += ' btn btn-warning'
        break;
      case '4':
      case '3':
      case '2':
      case '1':
        evaluationClass += ' btn btn-danger'
        break;
    }
  }
  $(target).attr('class', evaluationClass)
}

$(() => {
  $('.evaluation-rating').each((index, target) => {
    setEvaluationClass(target)
  })
})

$('select.evaluation-rating').on('change', (e) => {
  setEvaluationClass(e.target)
})
