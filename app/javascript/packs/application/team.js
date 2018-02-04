$(document).on('turbolinks:load', function() {
  if (typeof trainingChartData != 'undefined') {
    showChart('trainingChart', trainingChartData)
  }
  if (typeof matchChartData != 'undefined') {
    showChart('matchChart', matchChartData)
  }
})

function showChart(id, data) {
  var myChart = $('#' + id)[0]
  if (!myChart) {
    return;
  }

  var ctx = myChart.getContext('2d');
  var chart = new Chart(ctx, {
    type: 'bar',
    data: data,

    // Configuration options go here
    options: {
      maintainAspectRatio: false,
      scales: {
        xAxes: [{
          beginAtZero: true,
          ticks: {
            stepSize: 1,
            min: 0,
            autoSkip: false,
          },
        }],
        yAxes: [{
          beginAtZero: true,
          ticks: {
            stepSize: 1,
            min: 0,
          },
        }]
      },
    }
  });
}
