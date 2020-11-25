$(document).on('turbolinks:load', function() {
  if ($("[class^=glightbox]").length) {
    initLightbox();
  }
});

function initLightbox() {
  const lightbox = GLightbox({
    autoplayVideos: false,
    width: '90%',
    height: 'auto',
    preload: false
  });
}
