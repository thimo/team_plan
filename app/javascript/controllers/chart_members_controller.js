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
    var ctx = this.canvasTarget;
    var chart = new Chart(ctx, {
      type: 'line',
      data: JSON.parse(this.data.get("data")),

      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          xAxes: [{
          }],
          yAxes: [{
            beginAtZero: true,
          }]
        },
        title: {
            display: true,
            text: 'Actieve leden'
        },
      }
    });
  }
}
