$(document).on('turbolinks:load', function() {
  if ($('.history-table').length) {
    'use strict'
    new PerfectScrollbar('.history-table', {
      suppressScroll: "auto"
    });
  };
  
  if ($('.activity-table').length) {
    'use strict'
    new PerfectScrollbar('.activity-table', {
      suppressScroll: "auto"
    });
  };
});
