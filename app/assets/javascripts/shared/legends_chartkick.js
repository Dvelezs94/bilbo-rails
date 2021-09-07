$(document).on('turbolinks:load', function() {
  if ($("#chart-1").length) {
    var chart = Chartkick.charts["chart-1"]
    $("#chart-1").click(function(event) {
      for (i = 0; i < chart.rawData.length; i++) {
        if (chart.chart.data.datasets[i]._meta[Object.keys(chart.chart.data.datasets[i]._meta)[0]].hidden == true) {
          valor = true;
        } else {
          valor = false;
        }
        Chartkick.charts["chart-2"].chart.data.datasets[i].hidden = valor;
        Chartkick.charts["chart-3"].chart.data.datasets[i].hidden = valor;
      }
      Chartkick.charts["chart-2"].chart.update();
      Chartkick.charts["chart-3"].chart.update();
    });
  }
});
