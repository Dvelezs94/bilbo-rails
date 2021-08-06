$(document).on('turbolinks:load', function() {
  // use like https://url.com/path1?openModal=modalNewCampaign
  // this works for modals that are already in the view
  // if the modal loads through AJAX this won't work
  // use fetchModal function instead
  if ($.urlParam('openModal')){
    $("#" + $.urlParam('openModal')).modal('show')
  }

  // This needs an HTML element in the view that calls this modal through AJAX
  if ($.urlParam('fetchModal')){
    $('[data-target="' + "#" + $.urlParam('fetchModal') + '"]')[0].click()
  }
})
