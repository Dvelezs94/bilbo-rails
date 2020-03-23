//when is leaving, shows the loading, before it is stored in cache, revert all and show content to be useful in cache

//at visit on link show loading and hide anything of content
$(document).on('turbolinks:before-visit', function() {
  showLoading();
});

$(document).on('turbolinks:load', function() {
  hideLoading();
});
// cache shows before loading refreshed page, so this makes navigation faster for the user.
// this makes cached pages to show
$(document).on('turbolinks:before-cache', function() {
  hideLoading();
});

function hideLoading() {
  $(".spinner").removeClass("d-flex");
  $(".spinner").addClass("d-none");
  $(".content").show();
}

function showLoading() {
  $(".content").hide();
  $(".spinner").removeClass("d-none");
  $(".spinner").addClass("d-flex");

}
