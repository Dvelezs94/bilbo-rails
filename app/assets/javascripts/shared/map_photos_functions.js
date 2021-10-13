function get_single_photo(photo_id){
  elem = $("#reload_single_photo_"+photo_id);
  $.ajax({
    url: "/board_map_photos/" + photo_id + "/fetch_single_map_photo",
    beforeSend: function (){
      elem.addClass("rotate");
    },
    error: function(data) {
      show_error("Oops.. Ocurrió un error.. Intenta recargar la página")
    },
    complete: function() {
      elem.removeClass("rotate");
    }
  });
}
