// Changes an iframe element when called
function preview_iframe(input_elem, iframe_elem, auto_fix=true){
  if (is_valid_url($(input_elem).val())) {
    $(iframe_elem).attr("src", $(input_elem).val());
  } else {
    // If auto fix, then prepend https on the input element
    if (auto_fix) {
      $(input_elem).val("https://" + $(input_elem).val())
      // retry now with https
      preview_iframe(input_elem, iframe_elem)
    }
  }
}
