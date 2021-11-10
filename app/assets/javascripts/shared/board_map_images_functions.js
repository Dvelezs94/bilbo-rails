function appendPhotos(){
  $('#modalBoardPhotos').modal('hide');
  // $('body').removeClass('modal-open');
  // $('.modal-backdrop').remove();
  board_slug = $('#board_slug_default').val();
  content_board = $('#usedPhotos');
  content_board.val("");
  checkbox_selected = $('input[type="checkbox"]:checked');
  content_ids = [];
  $('input[type="checkbox"]:checked').each(function() {
     content = this.id.split("pickContent");
     content_ids.push(content[1]);
  });
  cont_ids = JSON.stringify(content_ids.filter((x) => {return typeof(x) == 'string';}))
  content_board.val(cont_ids);
  if($("#board_photo_ids").length){ $("#board_photo_ids").val(content_board.val()) }
  showMapPhotos(content_board, board_slug);
}

function showMapPhotos(selected_ids, board_slug){
  $.ajax({
    url:  "/board_map_photos/get_selected_map_photos",
    dataType: "script",
    data: {selected_photos: selected_ids.val(), board_slug: board_slug},
    success: function(data) {
    },
    error: function(data) {
      alert("Oops.. Ocurrio un error..");
    }
  });
}

function selectMapPhotos() {
  // choose content in wizard
    var items = $('div[data-content][data-processed="true"]');
    // clear event handler on click and reinitialize
    items.off("click");
    items.on("click", function(e) {
      e.preventDefault();
      var content_id = $(this).attr("data-content")
      // Click on nearest checkbox
      $("#pickContent" + content_id).prop("checked", !$("#pickContent" + content_id).prop("checked"));
      //append_content_live();
    });

    if ($('#usedPhotos').val().split(',').length) {
      selected_contents_ids = $('#usedPhotos').val().slice(1,-1).split(', ');
      var i;
      for (i = 0; i < selected_contents_ids.length; i++) {
        selected_ad = selected_contents_ids[i]
        if(!$("#pickContent" + selected_ad).prop("checked")){
          $("#pickContent" + selected_ad).prop("checked",true);
        }
      }
    }
    if($("#board_photo_ids").length){
      if ($('#board_photo_ids').val().split(',').length) {
        selected_contents_ids = $('#board_photo_ids').val().slice(1,-1).split(',');
        console.log(selected_contents_ids)
        var i;
        for (i = 0; i < selected_contents_ids.length; i++) {
          selected_ad = selected_contents_ids[i].slice(1,-1)
          if(!$("#pickContent" + selected_ad).prop("checked")){
            $("#pickContent" + selected_ad).prop("checked",true);
          }
        }
      }
    }
}

function createUpdateBoardMapPhotos(){
  console.log($("#usedPhotos").val(), $("#board_slug_default").val())
  $.ajax({
    url:  "/board_map_photos/create_or_update_board_map_photos",
    dataType: "script",
    data: {selected_photos: $('#usedPhotos').val(), board_slug: $('#board_slug_default').val()},
    success: function(data) {
    },
    error: function(data) {
      alert("Oops.. Ocurrio un error..");
    }
  });
}
