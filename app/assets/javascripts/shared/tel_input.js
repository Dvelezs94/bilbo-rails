$(document).on('turbolinks:load', function() {
  if ($("#user_phone_number").length) {
    $("#user_phone_number").intlTelInput({
      nationalMode: true,
      hiddenInput: 'user[phone_number]',
      formatOnInit: true,
      separateDialCode: true,
      initialCountry: "mx",
      formatOnDisplay: true,
      preferredCountries: ["mx", "us"]
    });
  }
});
