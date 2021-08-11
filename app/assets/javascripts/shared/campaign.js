function initDatePicker() {
    var dateFormat = 'yy-mm-dd';
    from = $('[id$=campaign_starts_at]')
    .datepicker({
      defaultDate: '+1w',
      numberOfMonths: 1,
      dateFormat: dateFormat,
      minDate: 0
    })
    .on('change', function() {
      var datepicker = getDate( $(this) )
      Date.prototype.addDays = function(days) {
        var date = new Date(datepicker.valueOf());
        date.setDate(date.getDate() + days);
        return date;
      }
      var date = new Date();
      to.datepicker('option','minDate', date.addDays(1) );
      setTimeout(function(){
        to.datepicker('show');
        }, 16);
    console.log(  document.getElementById('campaign_ends_at').click());
    }),
    to = $('[id$=campaign_ends_at]').datepicker({
      defaultDate: '+1w',
      numberOfMonths: 1,
      dateFormat: dateFormat,
      minDate: 1
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


function newCampaignOptions() {
  if($("#budget_card").length){
    $('.card-ad-link').click(function (e) {
      $("#budget_card").removeClass('wizard_selected_ad');
      e.preventDefault();
      $('.wizard_selected_ad').removeClass('wizard_selected_ad');
      $(this).find('div:first-child > .card').addClass('wizard_selected_ad');
      $('#typeCampaign').val($(this).attr('id'));
    });
    $("#budget_card").addClass('wizard_selected_ad');

  }

  $("[id^=objective_]").click(function(e){
    var objective_id = $(this).attr('data-objective');
    console.log(objective_id);
    $("[id^=objective_]").removeClass("selected_card");
    $(this).addClass('selected_card');
    $("#campaign_objective").val(objective_id);
    if (objective_id === "interaction") {
      $("#campaign_link_form").removeClass("d-none");
      $("#campaign_link").attr("required", true);
    } else {
      $("#campaign_link_form").addClass("d-none");
      $("#campaign_link").attr("required", false);
    }
  });

  initDatePicker();
}
