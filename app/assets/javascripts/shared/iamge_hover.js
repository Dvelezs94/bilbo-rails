$(document).on('turbolinks:load', function() {
  if($('.img-caption').length){
    hover_img();
  }
});

function hover_img(){
    $('.img-caption').on('mouseover mouseout', function(){
      $(this).find('figcaption').toggleClass('op-0');
    });
}
