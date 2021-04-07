$(document).on('turbolinks:load', function() {
  if ($('#gallery_ads').length) {
    $(window).scroll(function(e) {
      var url = $("#paginator a:visible").attr('href');
      if (url && $(window).scrollTop() >= ($(document).height() - $(window).height())) {
        $("#paginator a:visible").remove();
        $.getScript(url);
      }
    });
  }
});

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

function select_content() {
  // choose ad in wizard
  if ($('.card.wd-30p').length) {
    $('.card.wd-30p').click(function(e) {
      e.preventDefault();
      if ($(this).hasClass('wizard_selected_ad_blue')){
        $(this).removeClass('wizard_selected_ad_blue');
      }else {
      $(this).addClass('wizard_selected_ad_blue');  
      }

    });

    if ($('#'+$('#slug-board').val()).val().split(" ").length) {
      console.log("Slug: " + $("#slug-board").val());
      selected_contents_ids = $('#'+$('#slug-board').val()).val().split(" ");
      console.log("select_contents: "+ selected_contents_ids);
      //var selected_ad = $('#' + selected_ad_id);
      var i;
      for (i = 0; i < selected_contents_ids.length; i++) {
        selected_ad = selected_contents_ids[i]
        console.log("selected ad: " + selected_ad);
        select_content_mark = $(document.querySelectorAll('[data-content='+ "'"+selected_ad+"'" + ']'))
        console.log(select_content_mark)
        console.log("find: " + select_content_mark.find('.card.wd-30p'))
        select_content_mark.addClass('wizard_selected_ad_blue');
      }

    }
  }
}

function scroll_ads() {
  //get the ads with scroll infinite event
  setImageLoader();
  url = $("#paginator a:visible").attr('href');
  if (url && $('#ads_body').scrollTop() > 60) {
    $("#paginator a:visible").remove();
    $.getScript(url);
  }
}
