$(document).on('turbolinks:load', function() {
  if ($("[class^=glightbox]").length) {
    initLightbox();
  }
});

function initLightbox() {
  const lightbox = GLightbox({
    autoplayVideos: false,
    preload: false
  });
}
