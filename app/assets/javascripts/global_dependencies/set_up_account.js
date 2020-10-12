$(document).on('turbolinks:load', function() {
  if ($.urlParam('account') == "set") {
    $('#modalBusinessType').modal('show');
  }

  if($("#set_up_wizard").length){
    $('.card-ad-link').click(function (e) {
      $("#Small").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-users").removeClass("text-white")
      $("#small-txt").removeClass("text-primary")

      $("#Medium").removeClass('wizard_selected_ad_primary bg-primary');
      $(".ion-ios-people").removeClass("text-white")
      $("#medium-txt").removeClass("text-primary")

      $("#Large").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-home").removeClass("text-white")
      $("#large-txt").removeClass("text-primary")


      $("#Agency").removeClass('wizard_selected_ad_primary bg-primary');
      $(".fe-building").removeClass("text-white")
      $("#agency-txt").removeClass("text-primary")

      e.preventDefault();
      $('.wizard_selected_ad_primary bg-primary').removeClass('wizard_selected_ad_primary bg-primary');
      $(this).addClass('wizard_selected_ad_primary bg-primary');

      if ($(this).attr("id")== "Agency"){
        $(".fe-building").addClass("text-white")
        $("#agency-txt").addClass("text-primary")
      } else if ($(this).attr("id")== "Large"){
        $(".fe-home").addClass("text-white")
        $("#large-txt").addClass("text-primary")
      } else if ($(this).attr("id")== "Medium"){
        $(".ion-ios-people").addClass("text-white")
        $("#medium-txt").addClass("text-primary")
      }  else {
        $(".fe-users").addClass("text-white")
        $("#small-txt").addClass("text-primary")
      }
      $('#typeBusiness').val($(this).attr('id'));
    });

      $("#Small").addClass('wizard_selected_ad_primary bg-primary');
      $(".fe-users").addClass("text-white")
      $("#small-txt").addClass("text-primary")

    $("#btnEndStep1").click(function () {
      $("#step1").addClass('d-none');
      $("#step2").removeClass('d-none');
  });
  $("#btnReturn").click(function () {
    $("#step2").addClass('d-none');
    $("#step1").removeClass('d-none');
  });
  }

});
