// wizard pick board
$(document).on('turbolinks:load', function() {
  if($("[selected_bilbos_list_view]").length > 0) update_select_count(0); //so the list view gets text on load
  $("[selected_bilbos_list_view] .collapse").scrollTop(1).scrollTop(0); //fixes bug of scrollbar displayed when loading page of selected bilbos list view
  $(document).on('change', '.boardSelect', function (e) {
    $(".boardSelect").val(this.value); //put same value on all selects
    tab = $('#boardTab li').eq($(this).val()).find("a");
    tab.tab("show");
    //makes screen size selected tabpanel
    tabpanel_id = tab.attr("href").slice(1,);
    tabpanel = $("[board-info] [id='"+tabpanel_id+"']");
    hidden_tabpanels = $("[board-info] [role='tabpanel']:not([id='"+tabpanel_id+"'])");
    tabpanel.addClass("d-flex")
    hidden_tabpanels.removeClass("d-flex");
    infowindow.setContent(infowindow_content()) //change content of infowindow to current board
  });

  $(document).on('change',"#selected_boards",function(){
    var id = this.value;
    if (id != "") {
      showBoardInfo();
      if(window.fullScreenMap == true) mapToggle(false);
      $.ajax({
        url:  "/boards/get_info",
        dataType: "script",
        data: {selected_id: id, selected_boards: $("#campaign_boards").val()},
        success: function(data) {
          finishedLoadingBoardInfo();
        },
        error: function(data) {
          showFilterAndBilbos();
          alert("Oops.. Ocurrio un error..");
        }
      });
      $(this).val(""); //put placeholder again
    }
  });
  $(document).on("click", "[board_list_item]", function(){
    board_id = $(this).attr("board_list_item");
    selected_boards = $("#selected_boards");
    selected_boards.val(board_id);
    selected_boards.change();
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
  listElement = $(el).closest(".info-board").find("[board_list_item]").clone();
  if (selected_boards.find("option[value=" + id + "]").length == 0) {
    build_option = "<option value='" + id + "' data-max-impressions='" + max_impressions + "' data-price='" + cycle_price + "' new-height='" + new_height + "' data-cycle-duration='" + cycle_duration + "' data-slug='" + slug +"' new-width='" + new_width + "' lat='"+lat+"' lng='"+lng +"' >"+ address + "</option>"
    selected_boards.append(build_option);
    aspect_ratio_select.append(build_option);
    update_hidden_input(selected_boards);
    update_buttons("added", buttons_container);
    update_select_count(1);
    listElement.appendTo("[selected_bilbos_list]");
    $("[selected_bilbos_list]").scrollTop(1).scrollTop(0); //fixes bug of scrollbar update when adding bilbo
    $("[download_quote]").removeClass("d-none");
    if($("[selected_bilbos_list] [board_list_item]").length == 1) $("#collapseExample").collapse("show");
  }
}

function removeBilbo(el) {
  id = $(el).attr("data-id");
  slug = $(el).attr("data-slug");
  selected_boards = $("#selected_boards");
  aspect_ratio_select = $("#aspect_ratio_select");
  selected_boards.find("option[value=" + id + "]").remove();
  buttons_container = $("[board-info] [board_id='"+id+"']").find(".info-board");
  if(buttons_container) update_buttons("deleted", buttons_container);
  update_hidden_input(selected_boards);
  aspect_ratio_select.find("option[value=" + id + "]").remove();
  update_select_count(-1);
  $("#slug-"+slug).remove();
  updateHiddenFieldContent();
  if($(el).attr("list_view_remove")=="true") { // means it is removed in list item
    listElement = $(el).closest("[board_list_item]");
  } else {
    listElementId = $(el).closest(".info-board").find("[board_list_item]").attr("board_list_item");
    listElement = $("[selected_bilbos_list] [board_list_item='" + listElementId + "']");
  }
  listElement.remove();
  $("[selected_bilbos_list]").scrollTop(1).scrollTop(0); //fixes bug of scrollbar update when deleting bilbo
  if($("[selected_bilbos_list] [board_list_item]").length == 0) $("[download_quote]").addClass("d-none");
}

function update_select_count(number){
  placeholder = $("#selected_boards").find("option").eq(0);
  new_number = parseInt(placeholder.html().replace ( /[^\d.]/g, '' ), 10)+number;
  new_text = placeholder.html().replace(/\d+/g, new_number);
  placeholder.html(new_text);
  list_view_title = $("#list_view_title");
  list_view_title.html(new_text);
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
