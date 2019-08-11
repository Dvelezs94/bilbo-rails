$(document).on('turbolinks:load', function() {
  if ($("#dashboardWizard".length)) {
    // Enable Jquery steps
    $('#dashboardWizard').steps({
      headerTag: 'h3',
      bodyTag: 'section',
      autoFocus: true,
      titleTemplate: '<span class="number">#index#</span> <span class="title">#title#</span>',
      onFinished: function (event, currentIndex) {
        $(".edit_campaign").submit();
      }
    //   onStepChanging: function (event, currentIndex, newIndex) {
    //   if(currentIndex < newIndex) {
    //     // Step 1 form validation
    //     if(currentIndex === 0) {
    //       var fname = $('#firstname').parsley();
    //       var lname = $('#lastname').parsley();
    //
    //       if(fname.isValid() && lname.isValid()) {
    //         return true;
    //       } else {
    //         fname.validate();
    //         lname.validate();
    //       }
    //     }
    //
    //     // Step 2 form validation
    //     if(currentIndex === 1) {
    //       var email = $('#email').parsley();
    //       if(email.isValid()) {
    //         return true;
    //       } else { email.validate(); }
    //     }
    //   // Always allow step back to the previous step even if the current step is not valid.
    //   } else { return true; }
    // }
  });
    // End Jquery steps

    // Enable DatePick
    var dateFormat = 'dd/mm/yy',
      from = $('#campaign_starts_at')
      .datepicker({
        defaultDate: '+1w',
        numberOfMonths: 2
      })
      .on('change', function() {
        to.datepicker('option', 'minDate', getDate(this));
      }),
      to = $('#campaign_ends_at').datepicker({
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
     $("#campaign_starts_at").prop('disabled', true);
     $("#campaign_ends_at").prop('disabled', true);
     $('input[type=radio]').click(function(){
       if($(this).prop('id') == "date_campaign"){
         $("#campaign_starts_at").prop('disabled', false);
         $("#campaign_ends_at").prop('disabled', false);
       }else{
         $("#campaign_starts_at").prop('disabled', true);
         $("#campaign_starts_at").val("")
         $("#campaign_ends_at").prop('disabled', true);
         $("#campaign_ends_at").val("")
       }

     });
    // End toggle

    // choose ad in wizard
    $(".card-ad-link").click(function(e){
      e.preventDefault();
      $(".wizard_selected_ad").removeClass("wizard_selected_ad");
      $(this).find("div:first-child > .card").addClass("wizard_selected_ad");
      $("#campaign_ad_id").val($(this).attr("id"));
    });
    // end choose ad
  }
});
