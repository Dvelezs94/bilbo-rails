function initDatePicker() {
  $("#campaign_starts_at").datepicker({
    minDate: 0,
    dateFormat: 'yy-mm-dd'
  });
  $("#campaign_ends_at").datepicker({
    minDate: 1,
    dateFormat: 'yy-mm-dd'
  });
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
