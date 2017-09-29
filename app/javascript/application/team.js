$(function() {
  var ctx = document.getElementById('myChart').getContext('2d');
  var chart = new Chart(ctx, {
    // The type of chart we want to create
    type: 'bar',

    // The data for our dataset
    data: myChartData,

    // Configuration options go here
    options: {
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
})
