// Changes an iframe element when called
function preview_iframe(input_elem, iframe_elem){
  // console.log("salud");
  console.log($(input_elem));
  console.log($(iframe_elem));
  // console.log("attr: " + input.val());
  $(iframe_elem).attr("src", $(input_elem).val());
}
