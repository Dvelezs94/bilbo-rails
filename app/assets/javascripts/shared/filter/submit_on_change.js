$(document).on('turbolinks:load', function() {
  $('form#filter-bilbos').change(function(event) {
    //dont send form when location changes and not select one
    if (event.target.id != "search_autocomplete") $(this).find("input[type=submit]").click();
  });
  $( "form#filter-bilbos input[type=submit]" ).on("click", function(event) {
    window.maploading = toastr.info("Cargando", "", {"extendedTimeOut": 0, timeOut: 0, tapToDismiss: false});
  });
});
