// wizard pick board
$(document).on('turbolinks:load', function() {

  $(document).on('change', '#boardSelect', function (e) {
    console.log($(this).val());
    $('#boardTab li a').eq($(this).val()).tab('show');
  });

  $(document).on('click',"#selected_boards",function(){
    var id = this.value
    if (id != "") {
      $("#map-layout").removeClass("col-xl-12");
      $("#map-layout").addClass("col-xl-9");
      $("#boardInfo").addClass("d-none");
      $("#loading").addClass("placeholder-paragraph");
      $.ajax({
        url:  "/boards/get_info",
        dataType: "script",
        data: {selected_id: id, selected_boards: $("#campaign_boards").val()},
        success: function(data) {
          $("#map-layout").removeClass("col-xl-12");
          $("#map-layout").addClass("col-xl-9");
          $("#loading").removeClass("placeholder-paragraph");
          $("#boardInfo").removeClass("d-none");
        },
        error: function(data) {
          alert("Oops.. Ocurrio un error..");
        }
      });
    }
  });
});

function addBilbo(el) {
  id = $(el).attr("data-id");
  cycle_price = $(el).attr("data-price");
  new_width = $(el).attr("new-width");
  new_height = $(el).attr("new-height");
  buttons_container = $(el).closest(".info-board");
  address = $(el).attr("data-address");
  max_impressions = $(el).attr("data-max-impressions");
  selected_boards = $("#selected_boards");
  aspect_ratio_select = $("#aspect_ratio_select");
  if (selected_boards.find("option[value=" + id + "]").length == 0) {
    build_option = "<option value='" + id + "' data-max-impressions='" + max_impressions + "' data-price='" + cycle_price + "' new-height='" + new_height + "' new-width='" + new_width + "'>"+ address + "</option>"
    selected_boards.append(build_option);
    aspect_ratio_select.append(build_option);
    selected_boards.val(selected_boards.find("option:last").val() );
    update_hidden_input(selected_boards);
    update_buttons("added", buttons_container);
  }
  $('#boards_counter').html(parseInt($('#boards_counter').html(), 10)+1)
}

function removeBilbo(el) {
  id = $(el).attr("data-id");
  buttons_container = $(el).closest(".info-board");
  selected_boards = $("#selected_boards");
  aspect_ratio_select = $("#aspect_ratio_select");
  selected_boards.find("option[value=" + id + "]").remove();
  update_hidden_input(selected_boards);
  aspect_ratio_select.find("option[value=" + id + "]").remove();
  update_hidden_input(aspect_ratio_select);
  update_buttons("deleted", buttons_container);
  $('#boards_counter').html(parseInt($('#boards_counter').html(), 10)-1)
}

function update_hidden_input(selected_boards) {
  selected_boards_hidden = $("#campaign_boards");
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
