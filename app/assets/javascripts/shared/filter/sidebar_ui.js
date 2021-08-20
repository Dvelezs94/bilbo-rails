$(document).on('turbolinks:load', function() {
  $(document).on('click', '[return-filter]', function(e){
    if(window.fullScreenMap == true)  mapToggle(false);
    showFilterAndBilbos();
    google.maps.event.trigger(window.bilbomap, 'click'); //this event closes infowindow and unfocuses marker
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
function mapToggle(changeState = true) {
  map = $(".map-left-space");
  map.toggleClass("l-0-f");
  sidebar = $(".board-sidebar-width");
  sidebar.toggleClass("wd-0-f");
  if(changeState) window.fullScreenMap = sidebar.hasClass("wd-0-f")? true : false

}
