$(document).on('turbolinks:load', function() {
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
});
