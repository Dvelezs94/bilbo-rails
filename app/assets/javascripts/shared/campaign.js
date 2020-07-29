$(document).on('turbolinks:load', function() {
  if($("#budget_card").length){
  $('.card-ad-link').click(function (e) {
    $("#budget_card").removeClass('wizard_selected_ad')
    e.preventDefault();
    $('.wizard_selected_ad').removeClass('wizard_selected_ad');
    $(this).find('div:first-child > .card').addClass('wizard_selected_ad');
    $('#typeCampaign').val($(this).attr('id'));
  });

    $("#budget_card").addClass('wizard_selected_ad')
    }
});
