$(document).on('turbolinks:load', function() {
  if ($(".input-number").length) {
    var cleave = new Cleave('.input-number', {
      numeral: true,
      numeralThousandsGroupStyle: 'thousand'
    });
  }

  if ($(".input-number_integer").length) {
    var cleave = new Cleave('.input-number_integer', {
      numeral: true,
      numeralDecimalMark: '',
      delimiter: ''
    });
  }
});
