$(document).on('turbolinks:load', function() {
  if ($("#campaignsTable").length) {
    $('#campaignsTable').DataTable({
      responsive: true,
      pageLength: 25,
      language: {
        searchPlaceholder: 'Search...',
        sSearch: '',
        lengthMenu: '_MENU_ items/page'
      }
    });
  }

  if ($("#invoicesTable").length) {
    $('#invoicesTable').DataTable({
      responsive: true,
      pageLength: 25,
      language: {
        searchPlaceholder: 'Search...',
        sSearch: '',
        lengthMenu: '_MENU_ items/page'
      }
    });
  }
});
