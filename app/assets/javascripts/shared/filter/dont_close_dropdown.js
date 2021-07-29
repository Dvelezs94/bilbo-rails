$(document).on('turbolinks:load', function() {
  $('.dont-close-dropdown, #filter-bilbos input[type="submit"]').on('click', function (e) {
    //first element: prevents dropdown from closing when clicking inside it
    //second element: when js clicks submit (ocurrs when something changes in the filter), it closes dropdowns because its outside them, so i added it to stop propagation
    e.stopPropagation();
  });
});
