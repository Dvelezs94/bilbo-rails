$(document).on('turbolinks:load', function() {
  if ($("#board_impressions").length) {
    new Morris.Line({
      // ID of the element in which to draw the chart.
      element: 'board_impressions',
      // Chart data records -- each entry in this array corresponds to a point on
      // the chart.
      data: $("#board_impressions").data("stats"),
      // The name of the data record attribute that contains x-values.
      xkey: 'year',
      // A list of names of data record attributes that contain y-values.
      ykeys: ['value'],
      // Labels for the ykeys -- will be displayed when you hover over the
      // chart.
      labels: ['Value']
    });
  }
});
