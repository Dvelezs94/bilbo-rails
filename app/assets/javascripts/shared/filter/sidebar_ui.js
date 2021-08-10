$(document).on('turbolinks:load', function() {
  $(document).on('click', '[return-filter]', function(e){
    showFilterAndBilbos();
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
}
function finishedLoadingBoardInfo() {
  $("#loading").removeClass("placeholder-paragraph");
}
