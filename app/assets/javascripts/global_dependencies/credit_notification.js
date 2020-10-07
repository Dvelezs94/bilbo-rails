$(document).on('turbolinks:load', function() {
  if ($.urlParam('credits') == "true") {
    $('#modalNewPayment').modal('show');
  }
  if ($.urlParam('pa') == "pasa") {
    $('#modalBusinessType').modal('show');
  }
    $("#btnEndStep1").click(function () {
      $("#step1").addClass('hideMe');
      $("#step2").removeClass('hideMe');
  });
  $("#btnEndStep2").click(function () {
      $("#step2").addClass('hideMe');
      $("#step3").removeClass('hideMe');
  });
  $("#btnEndStep3").click(function () {
      // Whatever your final validation and form submission requires
      $("#modalBusinessType").modal("hide");
  });

  if($("#small-business").length){
    $('.card-ad-link').click(function (e) {

      $("#small-business").removeClass('wizard_selected_ad_info');
      $("#small").removeClass('wizard_selected_ad_info');
      $(".fe-users").removeClass("text-info")
      $("#small-txt").removeClass("text-info")

      $("#md-business").removeClass('wizard_selected_ad_info');
      $("#md").removeClass('wizard_selected_ad_info');
      $(".ion-ios-people").removeClass("text-info")
      $("#md-txt").removeClass("text-info")

      $("#big-business").removeClass('wizard_selected_ad_info');
      $("#big").removeClass('wizard_selected_ad_info');
      $(".fe-home").removeClass("text-info")
      $("#big-txt").removeClass("text-info")


      $("#agency-business").removeClass('wizard_selected_ad_info');
      $("#agency").removeClass('wizard_selected_ad_info');
      $(".fe-building").removeClass("text-info")
      $("#agency-txt").removeClass("text-info")

      e.preventDefault();
      $('.wizard_selected_ad_info').removeClass('wizard_selected_ad_info');
      $(this).find('div:first-child > .card').addClass('wizard_selected_ad_info');
      console.log(this);
      if ($(this).attr("id")== "agency-business"){
        $(".fe-building").addClass("text-info")
        $("#agency-txt").addClass("text-info")
      } else if ($(this).attr("id")== "big-business"){
        $(".fe-home").addClass("text-info")
        $("#big-txt").addClass("text-info")
      } else if ($(this).attr("id")== "md-business"){
        $(".ion-ios-people").addClass("text-info")
        $("#md-txt").addClass("text-info")
      }  else {
        $(".fe-users").addClass("text-info")
        $("#small-txt").addClass("text-info")
      }
      $('#typeCampaign').val($(this).attr('id'));
    });
    $("#small").addClass('wizard_selected_ad_info');
    $(".fe-users").addClass("text-info")
    $("#small-txt").addClass("text-info")
  }

});
