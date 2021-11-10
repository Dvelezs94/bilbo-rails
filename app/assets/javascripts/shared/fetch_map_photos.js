function fetch_project_map_photos(user_email){
  var email = $(user_email).val()
  if(email == ""){
    alert("El campo de email no puede estar vacío!")
    return 0;
  }
  $.ajax({
    type:"GET",
    url:  "/board_map_photos/images_new_board_modal",
    dataType: "script",
    data: {user_email: email, uploaded_photos: $("#uploadedphotos").val()},
    success: function(data) {
    },
    error: function(data) {
      alert("No se pudo encontrar el proyecto del usuario "+email);
    }
  });
}
