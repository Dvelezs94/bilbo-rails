function showAd() {
  ads = $(".board-ads").children();
  ads[~~(Math.random() * ads.length)];
}


$(document).on('turbolinks:load', function() {

  board_duration = parseInt($("#duration").val());

  // Start stream
  $(".start-stream").click(function(){
    alert("Starting streaming");
    $(".start-stream").hide();
    $(".board-ads").show();
  });

  // Stop stream
    $("body").keyup(function (e) {
      // Stop option only if its started
      if ($(".start-stream").is(":hidden")) {
        // stop if Escape key is pressed
        if (e.keyCode === 27) {
          alert("Stoping streaming");
          $(".start-stream").show();
          $(".board-ads").hide();
        }
      }
    });

})
