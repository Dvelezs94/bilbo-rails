$(document).on('turbolinks:load', function() {
  if ($("#dashboardWizard".length)) {
    // Enable Jquery steps
    $('#dashboardWizard').steps({
      headerTag: 'h3',
      bodyTag: 'section',
      autoFocus: true,
      titleTemplate: '<span class="number">#index#</span> <span class="title">#title#</span>'
    });
    // End Jquery steps

    // Enable DatePick
    var dateFormat = 'dd/mm/yy',
      from = $('#starts_at')
      .datepicker({
        defaultDate: '+1w',
        numberOfMonths: 2
      })
      .on('change', function() {
        to.datepicker('option', 'minDate', getDate(this));
      }),
      to = $('#ends_at').datepicker({
        defaultDate: '+1w',
        numberOfMonths: 2
      })
      .on('change', function() {
        from.datepicker('option', 'maxDate', getDate(this));
      });

    function getDate(element) {
      var date;
      try {
        date = $.datepicker.parseDate(dateFormat, element.value);
      } catch (error) {
        date = null;
      }

      return date;
    }
    // End Datepick

    // Toggle Datepick radio buttons
     $("#starts_at").prop('disabled', true);
     $("#ends_at").prop('disabled', true);
     $('input[type=radio]').click(function(){
       if($(this).prop('id') == "date_campaign"){
         $("#starts_at").prop('disabled', false);
         $("#ends_at").prop('disabled', false);
       }else{
         $("#starts_at").prop('disabled', true);
         $("#starts_at").val("")
         $("#ends_at").prop('disabled', true);
         $("#ends_at").val("")
       }

     });
    // End toggle

  }
});
