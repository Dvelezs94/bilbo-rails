$(document).on('turbolinks:load', function() {
$('[data-form="filter-bilbos"] #search_autocomplete').on('keypress', function(event) {
    if (event.keyCode == 13) {
      event.preventDefault();
    }
  });
});
