$(document).on('turbolinks:load', function() {
  $('form#filter-bilbos.send-on-change').change(function(event) {
    //dont send when changes ionslider
    if (event.target.id == "price_slider") return(0);
    //dont send form when location changes and not select one
    if (event.target.id != "search_autocomplete") $(this).find("input[type=submit]").click();
  });
  $( "form#filter-bilbos input[type=submit]" ).on("click", function(event) { //display loading
    window.maploading = toastr.info("Cargando", "", {"extendedTimeOut": 0, timeOut: 0, tapToDismiss: false});
  });
  $( "button[form=filter-bilbos]").on("click",function(){ //display loading when using the modal
    $( "form#filter-bilbos input[type=submit]" ).click();
  });
});
