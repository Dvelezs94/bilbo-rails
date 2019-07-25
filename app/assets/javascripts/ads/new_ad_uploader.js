// $(document).on('turbolinks:load', function() {
//   if ($("#new_Ad").length) {
//     var sendData = true;
//     $('#new_Ad').fileupload({
//       dataType: 'script',
//       autoUpload: false,
//       add: function(e, data) {
//         $("#send-new-ad").on("click", function() {
//           if (sendData) {
//             data.formData = $("#new_ad").serializeArray();
//             sendData = false;
//           }
//           data.submit();
//         });
//       },
//       done: function(e, data) {
//         sendData = true;
//       }
//     });
//   }
// });
