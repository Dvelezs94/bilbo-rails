$(document).on('turbolinks:load', function() {
  // hide hint
  $('#hideHint').click(function(event) {
    event.preventDefault();
    $(this).closest("div.card").toggleClass("fadeOutRightBig fadeInRightBig");
    $('#showHint').toggleClass("fadeInRightBig fadeOutRightBig");
  });

  // show hint
  $('#showHint').click(function(event) {
    event.preventDefault();
    $(this).toggleClass("fadeOutRightBig fadeInRightBig");
    $('#hideHint').closest("div.card").toggleClass("fadeInRightBig fadeOutRightBig");
  });
});
