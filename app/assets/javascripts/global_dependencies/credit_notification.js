$(document).on('turbolinks:load', function() {
  if ($.urlParam('credits') == "true") {
    $('#modalNewPayment').modal('show');
  }
});
