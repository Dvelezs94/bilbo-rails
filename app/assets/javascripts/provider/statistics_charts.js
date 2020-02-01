$(document).on('turbolinks:load', function() {
  // Campaigns count chart
  if ($("#chartjsChart1").length) {
    google.charts.load('current', {
      packages: ['corechart']
    });
    google.charts.setOnLoadCallback(drawCampaignCount);

    function drawCampaignCount() {
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
        backgroundColor: {
          fill: 'transparent'
        },
        legend: "none",
        height: "100%",
        width: "100%",
        chartArea: {
          height: "80%",
          width: "95%"
        }
      };

      var chart = new google.visualization.AreaChart($("#chartjsChart1")[0]);
      chart.draw(data, options);
    }
  }

  // Top providers chart
  if ($("#chartDonut").length) {
    google.charts.setOnLoadCallback(drawTopProviders);

    function drawTopProviders() {
      var datadonut = google.visualization.arrayToDataTable([
        ['Company', 'Campaign number'],
        ['Work', 11],
        ['Eat', 2],
        ['Commute', 2],
        ['Watch TV', 2]
      ]);

      var optionsdonut = {
        backgroundColor: {
          fill: 'transparent'
        },
        legend: "none",
        height: "100%",
        width: "100%",
        chartArea: {
          height: "85%",
          width: "85%"
        }
      };

      var chartdonut = new google.visualization.PieChart($("#chartDonut")[0]);
      chartdonut.draw(datadonut, optionsdonut);
    }
  }
});
