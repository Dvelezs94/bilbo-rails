$(document).on('turbolinks:load', function() {
$('body').on('shown.bs.modal', '#modalVerify', function (e) {
  var user_id = $('#verify_id').attr('data-user-id')
  $('#user-id').val(user_id);
 });
});
