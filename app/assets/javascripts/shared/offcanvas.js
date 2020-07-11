$(document).on('turbolinks:load', function() {
  // show offcanvas menu on wizard
  $('.off-canvas-menu').on('click', function(e){
    e.preventDefault();
    var target = $(this).attr('href');
    $(target).addClass('show');
  });
});
