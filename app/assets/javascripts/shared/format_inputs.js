$(document).on('turbolinks:load', function() {
  if ($(".input-number").length) {
    var cleave = new Cleave('.input-number', {
      numeral: true,
      numeralThousandsGroupStyle: 'thousand',
      numeralIntegerScale: 5
    });
  }

  if ($(".input-number_integer").length) {
    var cleave = new Cleave('.input-number_integer', {
      numeral: true,
      numeralDecimalMark: '',
      delimiter: ''
    });
  }

  if ($(".input-phone").length) {
    var cleave = new Cleave('.input-phone', {
      delimiter: '-',
      blocks: [3, 3, 4]
    });
  }

  if ($(".input-website").length) {
    var cleave = new Cleave('.input-website', {
      prefix: 'http://'
    });
  }
});
