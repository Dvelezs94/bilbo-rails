function fetch_project_map_photos(user_email){
  var email = $(user_email).val()
  $.ajax({
    type:"GET",
    url:  "/board_map_photos/images_new_board_modal",
    dataType: "script",
    data: {user_email: email},
    success: function(data) {
    },
    error: function(data) {
      alert("Ocurrio un error...");
    }
  });
}
