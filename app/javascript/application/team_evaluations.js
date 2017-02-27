$('select.evaluation-rating').on('change', (e) => {
  console.log('change')
  console.log(e.target.value)
  $(e.target).attr('class', 'custom-select evaluation-rating')
  if (!!e.target.value) {
    switch (e.target.value) {
      case 'goed':
        $(e.target).addClass('btn btn-success')
        break;
      case 'voldoende':
        $(e.target).addClass('btn')
        break;
      case 'matig':
        $(e.target).addClass('btn btn-warning')
        break;
      case 'onvoldoende':
        $(e.target).addClass('btn btn-danger')
        break;
    }
  }
})
