function get_single_content(){
  const elem = $(event.target);
  const card_elem = elem.closest(".card");
  const content_id = card_elem.data("content");
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
