function appendContentDefault(){
  $('#modalDefaultContent').modal('hide');
  board_slug = $('#board_slug_default').val();
  content_board = $('#board_default_contents');
  content_board.val("");
  checkbox_selected = $('input[type="checkbox"]:checked');
  content_ids = [];
  $('input[type="checkbox"]:checked').each(function() {
     content = this.id.split("pickContent");
     content_ids.push(content[1]);
  });
  cont_ids = content_ids.toString().replace(/,/g , " ");
  content_board.val(cont_ids);
  showContentDefault(content_board, board_slug);
}

function showContentDefault(content_board, board_slug){
  $.ajax({
    url:  "/board_default_contents/get_selected_default_contents",
    dataType: "script",
    data: {selected_contents: content_board.val(), board_slug: board_slug},
    success: function(data) {
    },
    error: function(data) {
      alert("Oops.. Ocurrio un error..");
    }
  });
}

function deleteContentDefault(content_id, board_slug){
  //find in the front-end the content to delete
  $('#content-delete-'+content_id+"-"+board_slug).remove();
  $('#content-'+content_id+"-"+board_slug).remove();
  //delete in the hiddenfield the contents
  var arr = $('#board_default_contents').val().split(" ");
    for( var i = 0; i < arr.length; i++){
        if ( arr[i] === content_id) {
            arr.splice(i, 1);
            i--;
        }
    }
    $('#board_default_contents').val(arr.toString().replace(/,/g , " "));
}

function selectDefaultContent() {
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

    if ($('#board_default_contents').val().split(" ").length) {
      selected_contents_ids = $('#board_default_contents').val().split(" ");
      var i;
      for (i = 0; i < selected_contents_ids.length; i++) {
        selected_ad = selected_contents_ids[i]
        if(!$("#pickContent" + selected_ad).prop("checked")){
          $("#pickContent" + selected_ad).prop("checked", !$("#pickContent" + selected_ad).prop("checked"));
        }
      }
    }
}

function createUpdateContentDefault(){
  $.ajax({
    url:  "/board_default_contents/create_or_update_default_content",
    dataType: "script",
    data: {selected_contents: $('#board_default_contents').val(), board_slug: $('#board_slug_default').val()},
    success: function(data) {
    },
    error: function(data) {
      alert("Oops.. Ocurrio un error..");
    }
  });
}
