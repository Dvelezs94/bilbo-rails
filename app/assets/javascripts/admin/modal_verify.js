$(document).on('turbolinks:load', function() {
  $('body').on('shown.bs.modal', '#modalVerify', function (e) {
    var user_id = $('#verify_id').attr('data-user-id')
    $('#user-id').val(user_id);
   });

   $('body').on('shown.bs.modal', '#modalDeny', function (e) {
     var user_id = $('#deny_id').attr('data-user-id')
     var oldUrl = $("#user").attr("href");
     var newUrl = oldUrl.replace("#", "/admin/users/"+ user_id +"/deny");
     $("#user").attr("href", newUrl);
    });

  $("#message").keyup(function() {
    var user_id = $('#deny_id').attr('data-user-id')
    var oldUrl = $("#user").attr("href");
    var text= $("#message").val();
    var newUrl = oldUrl.replace(oldUrl, "/admin/users/"+ user_id +"/deny?message="+ text);
    $("#user").attr("href", newUrl);
    });
});
