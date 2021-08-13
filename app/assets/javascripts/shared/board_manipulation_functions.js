// wizard pick board
$(document).on('turbolinks:load', function() {

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
