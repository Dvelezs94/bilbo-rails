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

  if ($("#boards-impressions-chart").length){
    var chart = Chartkick.charts["boards-impressions-chart"]
    $("#boards-impressions-chart").click(function (event) {
      for(var i=0; i < chart.rawData.length; i++){
        Chartkick.charts["daily-earnings-chart"].chart.data.datasets[i].hidden = chart.chart.data.datasets[i]._meta[Object.keys(chart.chart.data.datasets[i]._meta)[0]].hidden;
      }
      Chartkick.charts["daily-earnings-chart"].chart.update();
    });
  }
});
