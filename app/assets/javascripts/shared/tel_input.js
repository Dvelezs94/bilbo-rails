// formats phone numbers.
// Keep in mind the field of the phone SHOULD be named "phone_number"
$(document).on('turbolinks:load', function() {
  if ($("[id$=phone_number]").length) {
    initTelFormat();
  }
});

function initTelFormat(){
  $("[id$=phone_number]").each(function(){
    $(this).intlTelInput({
      nationalMode: true,
      hiddenInput: $(this).attr("name"),
      formatOnInit: true,
      separateDialCode: true,
      initialCountry: "mx",
      formatOnDisplay: true,
      preferredCountries: ["mx", "us"]
    });
  });
}
