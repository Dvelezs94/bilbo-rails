$(document).on('turbolinks:load', function() {
  if ($.urlParam('credits') == "true") {
    $('#modalNewPayment').modal('show');
  }
  if ($.urlParam('account') == "set") {
    $('#modalBusinessType').modal('show');
  }

  if($("#set_up_wizard").length){
    $('.card-ad-link').click(function (e) {

      $("#small").removeClass('wizard_selected_ad_primary bg-primary');
      $("#small-business").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-users").removeClass("text-white")
      $("#small-txt").removeClass("text-primary")

      $("#md").removeClass('wizard_selected_ad_primary bg-primary');
      $("#md-business").removeClass('wizard_selected_ad_primary bg-primary');
      $(".ion-ios-people").removeClass("text-white")
      $("#md-txt").removeClass("text-primary")

      $("#big").removeClass('wizard_selected_ad_primary bg-primary');
      $("#big-business").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-home").removeClass("text-white")
      $("#big-txt").removeClass("text-primary")


      $("#agency").removeClass('wizard_selected_ad_primary bg-primary');
      $("#agency-business").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-building").removeClass("text-white")
      $("#agency-txt").removeClass("text-primary")

      e.preventDefault();
      $('.wizard_selected_ad_primary bg-primary').removeClass('wizard_selected_ad_primary bg-primary');
      $(this).find('div:first-child > .card').addClass('wizard_selected_ad_primary bg-primary');
      console.log(this);
      if ($(this).attr("id")== "agency"){
        $(".fe-building").addClass("text-white")
        $("#agency-txt").addClass("text-primary")
      } else if ($(this).attr("id")== "big"){
        $(".fe-home").addClass("text-white")
        $("#big-txt").addClass("text-primary")
      } else if ($(this).attr("id")== "md"){
        $(".ion-ios-people").addClass("text-white")
        $("#md-txt").addClass("text-primary")
      }  else {
        $(".fe-users").addClass("text-white")
        $("#small-txt").addClass("text-primary")
      }
      $('#typeBusiness').val($(this).attr('id'));
    });

      $("#small-business").addClass('wizard_selected_ad_primary bg-primary');
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
