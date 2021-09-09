// Display bar chart for training and match presences

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "canvas" ]

  connect() {
    this.showChart()
  }

  disconnect() {
  }


  showChart() {
    var ctx = this.canvasTarget.getContext('2d');
    var chart = new Chart(ctx, {
      type: 'bar',
      data: JSON.parse(this.data.get("data")),

      options: {
        responsive: true,
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
              callback: function(value, index, values) {
                if (Math.floor(value) === value) {
                  return value;
                }
              }
            }
          }]
        },
        animation: {
          duration: 0
        },
      }
    });
  }
}
