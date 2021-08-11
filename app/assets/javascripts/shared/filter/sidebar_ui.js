$(document).on('turbolinks:load', function() {
  $(document).on('click', '[return-filter]', function(e){
    showFilterAndBilbos();
  });
  //fixes sidebar and map display when window is resized
  $(window).resize(function() {
    if ($(".board-sidebar-width").hasClass("wd-0-f") && window.innerWidth > 767) mapToggle();
  });
});

//transition effects of map sidebar elements
function showBoardInfo() {
  $('[board-info] [role="tabpanel"]').remove(); //removes old content of board info
  $("#loading").addClass("placeholder-paragraph"); //loading effect
  $('[board-info]').removeClass("translateX-100p");
  $("[filter-and-boards]").addClass("d-none");
}
function showFilterAndBilbos() {
  $('[board-info]').addClass("translateX-100p");
  $("[filter-and-boards]").removeClass("d-none");
  $('[board-info]').addClass("translateX-100p");
}
function finishedLoadingBoardInfo() {
  $("#loading").removeClass("placeholder-paragraph");
}
function mapToggle(e) {
  map = $(".map-left-space");
  map.toggleClass("l-0-f");
  sidebar = $(".board-sidebar-width");
  sidebar.toggleClass("wd-0-f");

  // container = $("#filter_and_results")
  // container.toggleClass("d-none");
  // //useful for displaying map of query without margins
  // the_screen = $('[screen-wrapper="true"]')
  // the_screen.toggleClass("screen-size-wrapper");
  // the_screen.toggleClass("screen-size-wrapper-map");
  // $("#filterBar").toggleClass("ht-100");
  // $("#filterBar").toggleClass("pd-t-10");
}
