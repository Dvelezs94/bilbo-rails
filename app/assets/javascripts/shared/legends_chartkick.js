$(document).on('turbolinks:load', function() {
  if ($("#daily-impressions-chart").length) {
    var chart = Chartkick.charts["daily-impressions-chart"]
    $("#daily-impressions-chart").click(function(event) {
      for (i = 0; i < chart.rawData.length; i++) {
        if (chart.chart.data.datasets[i]._meta[Object.keys(chart.chart.data.datasets[i]._meta)[0]].hidden == true) {
          valor = true;
        } else {
          valor = false;
        }
        Chartkick.charts["daily-invested-chart"].chart.data.datasets[i].hidden = valor;
        Chartkick.charts["peak-hours-chart"].chart.data.datasets[i].hidden = valor;
      }
      Chartkick.charts["daily-invested-chart"].chart.update();
      Chartkick.charts["peak-hours-chart"].chart.update();
    });
  }
});
