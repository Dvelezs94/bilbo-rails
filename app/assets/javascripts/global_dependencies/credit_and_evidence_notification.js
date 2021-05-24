$(document).on('turbolinks:load', function() {
  if ($.urlParam('credits') == "true") {
    $('#modalNewPayment').modal('show');
  }
  if ($.urlParam('evidence') == "true") {
    $('#modal-window-witnesses').modal('show');
  }
});
