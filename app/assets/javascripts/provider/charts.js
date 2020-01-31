$(document).on('turbolinks:load', function() {
  if ($("#chartjsChart1").length) {

    google.charts.load('current', {
      packages: ['corechart']
    });
    google.charts.setOnLoadCallback(drawBackgroundColor);

    function drawBackgroundColor() {
      var data = new google.visualization.DataTable();
      data.addColumn('date', 'Date');
      data.addColumn('number', 'Campaigns');

      data.addRows([
        [new Date(2016, 07, 01), 0],
        [new Date(2016, 07, 02), 10],
        [new Date(2016, 07, 03), 23],
        [new Date(2016, 07, 04), 17],
        [new Date(2016, 07, 05), 18],
        [new Date(2016, 07, 06), 9],
        [new Date(2016, 07, 07), 11],
        [new Date(2016, 07, 08), 27],
        [new Date(2016, 07, 09), 33],
        [new Date(2016, 07, 10), 40]
      ]);

      var options = {
        hAxis: {
          gridlines: {
            count: 0
          },
          baselineColor: '#fff',
          gridlineColor: '#fff',
          textPosition: 'none'
        },
        vAxis: {
          gridlines: {
            count: 0
          },
          baselineColor: '#fff',
          gridlineColor: '#fff',
          textPosition: 'none'
        },
        backgroundColor: { fill:'transparent' },
        legend: "none"
      };

      var chart = new google.visualization.AreaChart($("#chartjsChart1")[0]);
      chart.draw(data, options);
    }

  }
});
