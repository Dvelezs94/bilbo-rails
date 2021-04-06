$(document).on('turbolinks:load', function() {
  // hide hint
  $('#hideHint').click(function(event) {
    event.preventDefault();
    $(this).closest("div.card").toggleClass("fadeOutLeftBig fadeInLeftBig");
    $('#showHint').toggleClass("fadeInLeftBig fadeOutLeftBig");
  });

  // show hint
  $('#showHint').click(function(event) {
    event.preventDefault();
    $(this).toggleClass("fadeOutLeftBig fadeInLeftBig");
    $('#hideHint').closest("div.card").toggleClass("fadeInLeftBig fadeOutLeftBig");
  });
});
