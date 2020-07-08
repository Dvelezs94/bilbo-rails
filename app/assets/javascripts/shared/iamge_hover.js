$(document).on('turbolinks:load', function() {

    $('.img-caption').on('mouseover mouseout', function(){
      $(this).find('figcaption').toggleClass('op-0');
    });

});
