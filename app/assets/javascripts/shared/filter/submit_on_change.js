$(document).on('turbolinks:load', function() {
  $('[data-form="filter-bilbos"] :input').change(function(event) {
    //dont send when changes ionslider
    if (event.target.id == "price_slider") return(0);
    //dont send form when location changes and not select one
    if (event.target.id != "search_autocomplete") set_change_in("filter-bilbos");
  });

  $("#filter-bilbos").on('click', 'input[type=submit]', function(){
    window.maploading = toastr.info("Cargando", "", {"extendedTimeOut": 0, timeOut: 0, tapToDismiss: false});
  });

  $( "button[form=filter-bilbos]").on("click",function(){ //display loading when using the modal
    set_change_in("filter-bilbos");
  });
  $(".send-on-change").on("change", function(){
    $(this).find("input[type=submit]").click();
  });
});

function set_change_in(form_id) {
  form = $("#"+form_id); //get form
  form.trigger("change");
}
