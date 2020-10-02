$(document).on('turbolinks:load', function() {
  $("#pay-with-paypal").click(function(e) {
    e.preventDefault();
    $('#carouselPayment').carousel(0)
  });
  $("#pay-with-spei").click(function(e) {
    e.preventDefault();
    $('#carouselPayment').carousel(2)
  });
  $(".choose-another-payment-method").click(function(e) {
    e.preventDefault();
    $('#carouselPayment').carousel(1)
  });
});
