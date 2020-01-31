$(document).on('turbolinks:load', function() {
  $('.clipboard-btn').click(function (event) {
    event.preventDefault();
    var clipboard = new Clipboard('.clipboard-btn');
    clipboard.on('success', function(e) {
      alert("Text copied");
    });
  });
});
