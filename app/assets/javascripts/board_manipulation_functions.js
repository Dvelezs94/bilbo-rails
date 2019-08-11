// wizard pick board
$(document).on('turbolinks:load', function() {
  $(document).on('click',"#selected_boards",function(){
    var id = this.value
    $.ajax({
       url:  "/boards/get_info",
       dataType: "script",
       data: {id: id, selected_boards: $("#campaign_boards").val()},
       success: function(data) {
         $("#map-layout").removeClass("col-xl-12");
         $("#map-layout").addClass("col-xl-9");
         $("#boardInfo").removeClass("d-none");
       },
       error: function(data) {
         alert("parece que no estás conectado a internet.");
       }
    });
  });
});
function addBilbo(el) {
  id = $(el).attr("data-id");
  buttons_container = $(el).closest(".info-board");
  address = $(el).attr("data-address");
  selected_boards = $("#selected_boards");
  if (selected_boards.find("option[value=" + id + "]").length == 0) {
    selected_boards.append(new Option(address, id));
    selected_boards.val(selected_boards.find("option:last").val() );
    update_hidden_input(selected_boards);
    update_buttons("added", buttons_container);
  }
}

function removeBilbo(el) {
  id = $(el).attr("data-id");
  buttons_container = $(el).closest(".info-board");
  selected_boards = $("#selected_boards");
  selected_boards.find("option[value=" + id + "]").remove();
  update_hidden_input(selected_boards);
  update_buttons("deleted", buttons_container);
}

function update_hidden_input(selected_boards) {
  selected_boards_hidden = $("#campaign_boards");
  selected_boards_hidden.val(""); //erase all data for update
  var ids_list = []
  $.each(selected_boards.find("option"), function(index, elem) {
    ids_list.push( $(elem).attr("value") )
  });
  selected_boards_hidden.val(ids_list.join(","));
}

function update_buttons(action, buttons_container) {
  if (action == "added") {
    buttons_container.find(".add-bilbo").addClass("d-none");
    buttons_container.find(".remove-bilbo").removeClass("d-none");
  } else{
    buttons_container.find(".add-bilbo").removeClass("d-none");
    buttons_container.find(".remove-bilbo").addClass("d-none");
  }
}
// end pick board
