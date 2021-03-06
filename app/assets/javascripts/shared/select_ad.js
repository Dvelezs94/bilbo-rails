$(document).on('turbolinks:load', function() {
  // contents scroll
  if ($('#multimediaElements').length) {
    $(".filemgr-content-body").scroll(function(e) {
      var url = $("#paginator a:visible").attr('href');
      if (url && $(".filemgr-content-body").scrollTop() >= ($(document).height() - $(".filemgr-content-body").height())) {
        $("#paginator a:visible").remove();
        $.getScript(url);
      }
    });
  }
  // boards scroll
  if ($('#boardElements').length) {
    $(window).scroll(function(e) {
      var url = $("#paginator a:visible").attr('href');
      if (url && $(window).scrollTop() > ($(document).height() - $(window).height() - 900)) {
        $("#paginator a:visible").remove();
        $.getScript(url);
      }
    });
  }
  // contents wizard scroll
  scroll_wizard();
});

function select_content() {
  // choose content in wizard
  var items = $('div[data-content][data-processed="true"]');
  // clear event handler on click and reinitialize
  items.off("click");
  items.on("click", function(e) {
    e.preventDefault();
    var content_id = $(this).attr("data-content")
    // Click on nearest checkbox
    $("#pickContent" + content_id).prop("checked", !$("#pickContent" + content_id).prop("checked"));
    //append_content_live();
  });

  if ($('#' + $('#slug-board').val()).val().split(" ").length) {
    selected_contents_ids = $('#' + $('#slug-board').val()).val().split(" ");
    var i;
    for (i = 0; i < selected_contents_ids.length; i++) {
      selected_ad = selected_contents_ids[i]
      if (!$("#pickContent" + selected_ad).prop("checked")) {
        $("#pickContent" + selected_ad).prop("checked", !$("#pickContent" + selected_ad).prop("checked"));
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



function remove_on_click() {
  //for fix the bug select content
  if ($('div[data-content]').length) {
    $('div[data-content]').each(function() {
      $(this).unbind();
    });
  }
  if ($('.img-caption').length) {
    $('.img-caption').each(function() {
      $(this).unbind();
    });
  }
}

function scroll_wizard() {
  if ($('#content_space').length) {
    $("#content_space").scroll(function(e) {
      var url = $("#paginator a:visible").attr('href');
      if (url && $("#content_space").scrollTop() > 30) {
        $("#paginator a:visible").remove();
        $.getScript(url);
      }
    });
  }
}
