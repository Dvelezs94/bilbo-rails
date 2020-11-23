$(document).on('turbolinks:load', function() {
  if ($(".js-smartPhoto").length) {
    initSmartPhoto();
  }
});

function initSmartPhoto() {
  $(".js-smartPhoto").SmartPhoto();
}
