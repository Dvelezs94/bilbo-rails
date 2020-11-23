function select_ad() {
  // choose ad in wizard
  if ($('.wizard-height').length) {
    $('.card-ad-link').click(function(e) {
      e.preventDefault();
      $('.wizard_selected_ad').removeClass('wizard_selected_ad');
      $(this).find('div:first-child > .card').addClass('wizard_selected_ad');
      $('#campaign_ad_id').val($(this).attr('id'));
    });

    if ($('#campaign_ad_id').val()) {
      var selected_ad_id = $('#campaign_ad_id').val();
      var selected_ad = $('#' + selected_ad_id);
      selected_ad
        .find('div:first-child > .card')
        .addClass('wizard_selected_ad');
    }
  }
}

function scroll_ads() {
  //get the ads with scroll infinite vent
  var url = $("#paginator a:visible").attr('href');
  if (url && $('#ads_body').scrollTop() > 20) {
    if ($('#paginator a:visible')) {
      ajaxLoading = true;
      $.ajax({
        url: url,
        beforeSend: function() {
          $('.loadingio-spinner-pulse-vlx1rsm1qjd').removeClass('d-none');
          $("#paginator a").hide();
        },
        complete: function() {
          $('.loadingio-spinner-pulse-vlx1rsm1qjd').addClass('d-none');
          $("#paginator a").show();
        },
      });
    }
  }
}
