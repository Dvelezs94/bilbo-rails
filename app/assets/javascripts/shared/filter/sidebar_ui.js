$(document).on('turbolinks:load', function() {
  $(document).on('click', '[data-single-board]', function(e){
    $("[filter-and-boards]").addClass("d-none");
    $("[board-info]").removeClass("d-none");
  });
  $(document).on('click', '[return-filter]', function(e){
    $("[filter-and-boards]").removeClass("d-none");
    $("[board-info]").addClass("d-none");
  });
});
