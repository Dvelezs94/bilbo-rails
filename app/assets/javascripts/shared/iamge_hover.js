$(document).on('turbolinks:load', function() {
    hover_img();
});

function hover_img(){
    $('.img-caption').on('mouseover mouseout', function(){
      $(this).find('figcaption').toggleClass('op-0');
    });
}
