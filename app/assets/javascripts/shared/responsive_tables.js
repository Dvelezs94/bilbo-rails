$(document).on('turbolinks:load', function() {
  if ($("#userCampaignTable").length) {
    $('#userCampaignTable').DataTable({
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
    $('.dataTables_length select').select2({ minimumResultsForSearch: Infinity });
  }

  if ($("#invoicesTable").length) {
    $('#invoicesTable').DataTable({
      ordering: false,
      responsive: true,
      pageLength: 25,
      language: {
        searchPlaceholder: 'Search...',
        sSearch: '',
        lengthMenu: '_MENU_ items/page'
      }
    });
    $('.dataTables_length select').select2({ minimumResultsForSearch: Infinity });
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
