$(document).on('turbolinks:load', function() {
  if ($("#configurationTab".length)) {

    $("#multimediaLink").click(function(e) {
      e.preventDefault();
      $("#multimediaTab").removeClass("d-none");
      $("#configurationTab").addClass("d-none");
      $("#multimediaLink").addClass("active");
      $("#configurationLink").removeClass("active");
    });

    $("#configurationLink").click(function(e) {
      e.preventDefault();
      $("#multimediaTab").addClass("d-none");
      $("#configurationTab").removeClass("d-none");
      $("#multimediaLink").removeClass("active");
      $("#configurationLink").addClass("active");
    });
  }
});
