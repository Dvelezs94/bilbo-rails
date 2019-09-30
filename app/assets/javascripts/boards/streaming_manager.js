$(document).on('turbolinks:load', function() {

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
        if (e.keyCode === 27) {
          alert("Stoping streaming");
          $(".start-stream").show();
          $(".board-ads").hide();
        }
      }
    });

})
