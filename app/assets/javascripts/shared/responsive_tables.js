$(document).on('turbolinks:load', function() {
  if ($("#campaignsTable").length) {
    $('#campaignsTable').DataTable({
      responsive: true,
      pageLength: 25,
      columnDefs: [ {
        "targets"  : 'no-sort',
        "orderable": false,
      }],
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
      columnDefs: [ {
        "targets"  : 'no-sort',
        "orderable": false,
      }],
      language: {
        searchPlaceholder: 'Search...',
        sSearch: '',
        lengthMenu: '_MENU_ items/page'
      }
    });
  }

  if ($("#boardsTable").length) {
    $('#boardsTable').DataTable({
      responsive: true,
      pageLength: 25,
      columnDefs: [ {
        "targets"  : 'no-sort',
        "orderable": false,
      }],
      language: {
        searchPlaceholder: 'Search...',
        sSearch: '',
        lengthMenu: '_MENU_ items/page'
      }
    });
  }
});
