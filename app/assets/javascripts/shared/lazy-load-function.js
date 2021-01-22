$(document).on('turbolinks:load', function() {
  if ($('.lazy-img').length) {
    setImageLoader();
  }
});

function setImageLoader() {
  $('.lazy-img').imageloader();
}
