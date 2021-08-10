// wizard pick board
$(document).on('turbolinks:load', function() {

  $(document).on('change', '#boardSelect', function (e) {
    $('#boardTab li a').eq($(this).val()).tab('show');
  });

  $(document).on('change',"#selected_boards",function(){
    var id = this.value
    if (id != "") {
      board = $(this).find("option:selected");
      lat = board.attr("lat");
      lng = board.attr("lng");
      window.markersLoaded = false; //set to true when markers loaded in build_markers
      window.bilbomap.setCenter(new google.maps.LatLng(lat, lng)); //change location so the board is shown
      waitForMarkersLoad(function() { //wait for boards marker load so it can be clicked in map
        OpenInMap(board[0]);
      });
      $(this).val(""); //put placeholder again
    }
  });
});

function addBilbo(el) {
  id = $(el).attr("data-id");
  lat = $(el).attr("data-lat");
  lng = $(el).attr("data-lng");
  cycle_price = $(el).attr("data-price");
  new_width = $(el).attr("new-width");
  cycle_duration = $(el).attr("data-cycle-duration");
  new_height = $(el).attr("new-height");
  slug = $(el).attr("data-slug");
  buttons_container = $(el).closest(".info-board");
  address = $(el).attr("data-address");
  max_impressions = $(el).attr("data-max-impressions");
  selected_boards = $("#selected_boards");
  aspect_ratio_select = $("#aspect_ratio_select");
  if (selected_boards.find("option[value=" + id + "]").length == 0) {
    build_option = "<option value='" + id + "' data-max-impressions='" + max_impressions + "' data-price='" + cycle_price + "' new-height='" + new_height + "' data-cycle-duration='" + cycle_duration + "' new-width='" + new_width + "' lat='"+lat+"' lng='"+lng +"' >"+ address + "</option>"
    selected_boards.append(build_option);
    aspect_ratio_select.append(build_option);
    selected_boards.val(selected_boards.find("option:last").val() );
    update_hidden_input(selected_boards);
    update_buttons("added", buttons_container);
  }
  update_select_count(1);
}

function removeBilbo(el) {
  id = $(el).attr("data-id");
  slug = $(el).attr("data-slug");
  buttons_container = $(el).closest(".info-board");
  selected_boards = $("#selected_boards");
  aspect_ratio_select = $("#aspect_ratio_select");
  selected_boards.find("option[value=" + id + "]").remove();
  update_hidden_input(selected_boards);
  aspect_ratio_select.find("option[value=" + id + "]").remove();
  update_hidden_input(aspect_ratio_select);
  update_buttons("deleted", buttons_container);
  update_select_count(-1);
  $("#slug-"+slug).remove();
  updateHiddenFieldContent();
}

function update_select_count(number){
  placeholder = $("#selected_boards").find("option").eq(0);
  new_number = parseInt(placeholder.html(), 10)+number;
  new_text = placeholder.html().replace(/^[0-9]/g, new_number);
  placeholder.html(new_text);
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
