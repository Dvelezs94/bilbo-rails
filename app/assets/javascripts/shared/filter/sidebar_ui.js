$(document).on('turbolinks:load', function() {

  $(document).on('click', '[return-filter]', function(e){
    $("[filter-and-boards]").removeClass("translateX-m100p");
    $('[board-info]').addClass("translateX-100p");
  });
});
