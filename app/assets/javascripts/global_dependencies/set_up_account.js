$(document).on('turbolinks:load', function() {
  if ($.urlParam('account') == "set") {
    $('#modalBusinessType').modal('show');
  }

  if($("#set_up_wizard").length){
    $('.card-ad-link').click(function (e) {

      $("#small").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-users").removeClass("text-white")
      $("#small-txt").removeClass("text-primary")

      $("#medium").removeClass('wizard_selected_ad_primary bg-primary');
      $(".ion-ios-people").removeClass("text-white")
      $("#medium-txt").removeClass("text-primary")

      $("#large").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-home").removeClass("text-white")
      $("#large-txt").removeClass("text-primary")


      $("#agency").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-building").removeClass("text-white")
      $("#agency-txt").removeClass("text-primary")

      e.preventDefault();
      $('.wizard_selected_ad_primary bg-primary').removeClass('wizard_selected_ad_primary bg-primary');
      $(this).addClass('wizard_selected_ad_primary bg-primary');

      if ($(this).attr("id")== "agency"){
        $(".fe-building").addClass("text-white")
        $("#agency-txt").addClass("text-primary")
      } else if ($(this).attr("id")== "large"){
        $(".fe-home").addClass("text-white")
        $("#large-txt").addClass("text-primary")
      } else if ($(this).attr("id")== "medium"){
        $(".ion-ios-people").addClass("text-white")
        $("#medium-txt").addClass("text-primary")
      }  else {
        $(".fe-users").addClass("text-white")
        $("#small-txt").addClass("text-primary")
      }
      $('#typeBusiness').val($(this).attr('id'));
    });

      $("#small").addClass('wizard_selected_ad_primary bg-primary');
      $(".fe-users").addClass("text-white")
      $("#small-txt").addClass("text-primary")

    $("#btnEndStep1").click(function () {
      $("#step1").addClass('hideMe');
      $("#step2").removeClass('hideMe');
  });
  $("#btnReturn").click(function () {
    $("#step2").addClass('hideMe');
    $("#step1").removeClass('hideMe');
  });
  }

});
