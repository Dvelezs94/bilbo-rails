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
      // commented because this causes the `actions` dropdown to dissapear
      // scrollX: true,
      // fixedColumns:   {
      //   leftColumns: 2
      // }
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


$(document).on('turbolinks:before-cache', function() {
  if ($('#userCampaignTable').DataTable() != null) $('#userCampaignTable').DataTable().destroy();
  if ($('#invoicesTable').DataTable() != null) $('#invoicesTable').DataTable().destroy();
  if ($('#boardsTable').DataTable() != null) $('#boardsTable').DataTable().destroy();
  if ($('#campaignsTable').DataTable() != null) $('#campaignsTable').DataTable().destroy();
});
