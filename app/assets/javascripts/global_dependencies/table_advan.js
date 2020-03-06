$(function(){
  $('#table_camp').DataTable({
    language: {
      searchPlaceholder: 'Search...',
      sSearch: '',
      lengthMenu: '_MENU_ items/page',
    }
  });
  $('.dataTables_length select').select2({ minimumResultsForSearch: Infinity });
});
