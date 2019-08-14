$(document).on('turbolinks:load', function() {
  if ($(".input-number").length) {
    var cleave = new Cleave('.input-number', {
      numeral: true,
      numeralThousandsGroupStyle: 'thousand'
    });
  }
});
