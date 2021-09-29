$(document).on('turbolinks:load', function () {
  if ($("#daily-impressions-chart").length) {
    var chart = Chartkick.charts["daily-impressions-chart"];
    var chart2 = Chartkick.charts["daily-invested-chart"];
    var chart3 = Chartkick.charts["peak-hours-chart"];
    var numberColorsGenerate = parseInt($('#totalCharts').val());
    var validation = [];
    var colors = [];
    //add random colors to charts
    for (var y = 0; y <= numberColorsGenerate; y++) {
      while (true) {
        var randomColor = random_rgba();
        for (var i = 0; i < chart.options.colors.length; i++) {
          colorChart = chart.options.colors[i].replace('rgb', '').replace("(", '').replace(")", '').split(",");
          while (true) {
            if (isNeighborColor(randomColor.replace('rgb', '').replace("(", '').replace(")", '').split(","), colorChart) == false) {
              validation.push(true);
            } else {
              validation.push(false);
              i = 0;
            }
            if (validation.includes(false)) {
              randomColor = random_rgba();
              validation = [];
            } else {
              break;
            }
          }
        }
        if (colors.length == 0) {
          colors.push(randomColor);
          chart.options.colors.push(randomColor);
          chart2.options.colors.push(randomColor);
          chart3.options.colors.push(randomColor);
          break;
        } else {
          colorArray = colors[y - 1].replace('rgb', '').replace("(", '').replace(")", '').split(",");
          if (isNeighborColor(randomColor.replace('rgb', '').replace("(", '').replace(")", '').split(","), colorArray) == false) {
            validation.push(true);
          } else {
            validation.push(false);
          }
          if (validation.includes(false)) {
            randomColor = random_rgba();
            validation = [];
          } else {
            colors.push(randomColor);
            chart.options.colors.push(randomColor);
            chart2.options.colors.push(randomColor);
            chart3.options.colors.push(randomColor);
            break;
          }
        }
      }
    }
    
    //enable or disable legends on charts
    $("#daily-impressions-chart").click(function (event) {
      for (i = 0; i < chart.rawData.length; i++) {
        if (chart.chart.data.datasets[i]._meta[Object.keys(chart.chart.data.datasets[i]._meta)[0]].hidden == true) {
          valor = true;
        } else {
          valor = false;
        }
        chart2.chart.data.datasets[i].hidden = valor;
        chart3.chart.data.datasets[i].hidden = valor;
      }
      chart2.chart.update();
      chart3.chart.update();
    });
  }
});


function isNeighborColor(color1, color2, tolerance) {
  if (tolerance == undefined) {
    tolerance = 32;
  }
  return Math.abs(color1[0] - color2[0]) <= tolerance &&
    Math.abs(color1[1] - color2[1]) <= tolerance &&
    Math.abs(color1[2] - color2[2]) <= tolerance;
}

function random_rgba() {
  var o = Math.round,
    r = Math.random,
    s = 255;
  return 'rgb(' + o(r() * s) + ',' + o(r() * s) + ',' + o(r() * s) + ')';
}
