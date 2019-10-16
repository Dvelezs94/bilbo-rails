function showAd() {
    ads = $(".board-ad-inner");
    chosen = Math.floor(Math.random() * ads.length);

    if (typeof newAd !== 'undefined') {
      oldAd = newAd;
      oldAd.css({display: "none"});
    }
    newAd = ads.eq(chosen).css({display: "block"});
}

$(document).on('turbolinks:load', function() {
  var rotateAds;
  // Convert seconds to milliseconds
  board_duration = parseInt($("#duration").val()) * 1000;

  // Start stream
  $(".start-stream").click(function(){
    $(".start-stream").hide();
    $(".board-ads").show();
    rotateAds = setInterval(showAd, board_duration);
  });

  // Stop stream
    $("body").keyup(function (e) {
      // Stop option only if its started
      if ($(".start-stream").is(":hidden")) {
        // stop if Escape key is pressed
        if (e.keyCode === 27) {
          $(".start-stream").show();
          $(".board-ads").hide();
          clearInterval(rotateAds);
          $(".board-ad-inner").css({display: "none"});
        }
      }
    });

})
