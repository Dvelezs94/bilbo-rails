$(document).on('turbolinks:load', function() {
  // use like https://url.com/path1?openModal=modalNewCampaign
  if ($.urlParam('openModal')){
    $("#" + $.urlParam('openModal')).modal('show')
  }
})
