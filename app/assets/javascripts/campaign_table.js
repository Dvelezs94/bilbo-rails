$(document).on('turbolinks:load', function() {
  if ($("#campaignsTable".length)) {
    $('#campaignsTable').DataTable({
      responsive: true,
      language: {
        searchPlaceholder: 'Search...',
        sSearch: '',
        lengthMenu: '_MENU_ items/page'
      }
    });
  }
});
