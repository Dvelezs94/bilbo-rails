function get_single_content(content_id){
  elem = $("#reload_single_content_" + content_id);
  $.ajax({
    url:  "/contents_board_campaign/"+ content_id +"/fetch_single_wizard_content",
    beforeSend: function () {
      elem.addClass("rotate");
    },
    error: function(data) {
      show_error("Oops.. Ocurrio un error.. Intenta recargar la página");
    },
    complete: function() {
      elem.removeClass("rotate");
    }
  });
};

// automatic refreshes content every 5 seconds for the uploaded content
function auto_fetch_content(content_id) {
  //console.log("attempting to auto fetch content for: " + content_id)
  var tid = setInterval(function() {
    div_elem = $("#reload_single_content_" + content_id);
    if (div_elem.length) { // if element hasn't been processed yet, so keep trying
      get_single_content(content_id);
    } else { // the element was processed correctly, so no need to keep running
      clearInterval(tid);
    }
  }, 5000);
}
