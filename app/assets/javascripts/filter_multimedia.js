$(document).on('turbolinks:load', function() {
  if ($("#searchMultimedia").length) {
    $("#searchMultimedia").on("input", function() {
      var value = $(this).val().toLowerCase();
      $("#multimediaElements .flex-0-f").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
      });
    });

  }
});
