$(document).on('turbolinks:load', function() {
  if ($('[data-toggle="tooltip"]').length) {
    $('[data-toggle="tooltip"]').tooltip();
  }
});
