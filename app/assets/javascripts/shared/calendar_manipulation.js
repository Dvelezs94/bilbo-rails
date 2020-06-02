$(document).on('turbolinks:load', function() {
  if ($("[id$=start_date]").length) {
    var dateFormat = 'mm-dd-yy',
    from = $('[id$=start_date]')
    .datepicker({
      defaultDate: '+1w',
      numberOfMonths: 1,
      dateFormat: dateFormat
    })
    .on('change', function() {
      to.datepicker('option','minDate', getDate( $(this) ) );
    }),
    to = $('[id$=end_date]').datepicker({
      defaultDate: '+1w',
      numberOfMonths: 1,
      dateFormat: dateFormat
    })
    .on('change', function() {
      from.datepicker('option','maxDate', getDate( $(this) ) );
    });

    function getDate( element ) {
      var date;
      try {
        date = $.datepicker.parseDate( dateFormat, element[0].value );

      } catch( error ) {
        date = null;
      }
      return date;
    }
  }
});
