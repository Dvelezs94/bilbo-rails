$(document).on('turbolinks:load', function() {
  if ($.urlParam('account') == "set") {
    $('#modalBusinessType').modal('show');
  }

  if ($("#set_up_wizard").length) {

    $("#Small").addClass('wizard_selected_ad_primary bg-primary text-white');
    $("#Small-txt").addClass("text-primary");

    $('.card-ad-link').click(function(e) {
      card = '#' + $(document.getElementsByClassName("wizard_selected_ad_primary")).attr('id');

      $(card).removeClass('wizard_selected_ad_primary bg-primary text-white');
      $(card + '-txt').removeClass('text-primary')
      $(this).addClass('wizard_selected_ad_primary bg-primary text-white');
      $('#' + $(this).attr('id') + '-txt').addClass('text-primary');
      $('#typeBusiness').val($(this).attr('id'));
    });

    $("#btnEndStep1").click(function() {
      $("#step1").addClass('d-none');
      $("#step2").removeClass('d-none');
    });

    $("#btnReturn").click(function() {
      $("#step2").addClass('d-none');
      $("#step1").removeClass('d-none');
    });
  }

});
