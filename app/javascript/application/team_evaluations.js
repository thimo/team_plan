function setEvaluationClass(target) {
  $(target).removeClass('btn').removeClass('btn-success').removeClass('btn-warning').removeClass('btn-danger')
  if (!!target.value) {
    $(target).removeClass('form-control-error')

    switch (target.value) {
      case '10':
      case '9':
      case '8':
        $(target).addClass('btn').addClass('btn-success')
        break;
      case '7':
      case '6':
        $(target).addClass('btn').addClass('btn-primary')
        break;
      case '5':
        $(target).addClass('btn').addClass('btn-warning')
        break;
      case '4':
      case '3':
      case '2':
      case '1':
        $(target).addClass('btn').addClass('btn-danger')
        break;
    }
  }
}

$(() => {
  $('.team_evaluation select').each((index, target) => {
    setEvaluationClass(target)
  })
})

$('.team_evaluation select').on('change', (e) => {
  setEvaluationClass(e.target)
})
