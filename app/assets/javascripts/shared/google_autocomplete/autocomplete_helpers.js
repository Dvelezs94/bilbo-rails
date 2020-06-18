//this has number 2 respect the initializers of location autocompletes because otherwise blur doesnt work, maybe event declaration orders matters...
$(document).on('turbolinks:load', function() {
  //location autocompletes needs this events to better ui experience
  autocom_loc_func("#search_autocomplete");

});

//this is still useful on google because it autocompletes
function autocom_loc_func(id) {
  //remove info on click
  $(id).on("focus", function(e) {
    window.location_val = $(this).val();
    $(this).val("");
  });

  if (id == "#form_autocomplete_gig" || id == "#form_autocomplete_req" || id == "#menu_autocomplete" || id == "#search_autocomplete" || id=="#config_autocomplete") {
    $(id).blur(function(e) {
        //if no option selected, retype location
        if ($(this).val() != window.location_val) {
          $(this).val(window.location_val);
       }
    });
   }
}
