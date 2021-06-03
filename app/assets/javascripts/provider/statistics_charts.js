$(document).on('turbolinks:load', function() {

  if ($('#campaignsTable').length){
    $(function(){
      var table =  $('#campaignsTable').DataTable({
        dom: 'Bfrtip',
        buttons: {
          buttons: [
             { text: $("#in_review_text").text(),
               attr: {id: 'review' },
               action: function () {multiple_update("in_review")},
               className: "btn btn-outline-warning"
             },
             {  text: $("#approved_text").text(),
                attr: {id: 'approved'},
                action: function () {multiple_update("approved")},
                className: "btn btn-outline-success"
             },
             {  text : $("#denied_text").text(),
                attr: { id: 'denied'},
                action: function () {multiple_update("denied")},
                className: "btn btn-outline-danger"
             }
          ],
        dom: {
            button: { className: ""},
            buttonLiner: { tag: null }
            }
          },
        language: {
          searchPlaceholder: 'Search...',
          sSearch: '',
          lengthMenu: '_MENU_ items/page'
        },
        responsive: true,
        pageLength: 100,
        columnDefs: [
          { orderable: false}
        ]
      });

      $('.dataTables_length select').select2({ minimumResultsForSearch: Infinity });
      $('#checkboxSelectAll').on('click', function(){
         // Get all rows with search applied
         var rows = table.rows({ page: 'current'}).nodes();
         var counterChecked = 0;
         // Check/uncheck checkboxes for all rows in the table
         $('input[type="checkbox"]', rows).prop('checked', this.checked);
         is_checked();
      });

      // Handle click on checkbox to set state of "Select all" control
      $('#campaignsTable tbody').on('change', 'input[type="checkbox"]', function(){
         // If checkbox is not checked
         is_checked();
         if(!this.checked){
            var el = $('#checkboxSelectAll').get(0);
            // If "Select all" control is checked and has 'indeterminate' property
            if(el && el.checked && ('indeterminate' in el)){
               // Set visual state of "Select all" control
               // as 'indeterminate'
               el.indeterminate = true;
            }
         }
      });
      $('#denied').prop("disabled", true)
      $('#review').prop("disabled", true)
      $('#approved').prop("disabled", true)
      var urlParams = new URLSearchParams(window.location.search);
      if(urlParams.has('q')){
        $('#review').hide()
      }else{
        $('#approved').hide()
      }
    });
  }

  // Campaigns count chart
  if ($("#chartjsChart1").length) {
    google.charts.load('current', {
      packages: ['corechart']
    });
    google.charts.setOnLoadCallback(drawCampaignCount);

    function drawCampaignCount() {
      var data = new google.visualization.DataTable();
      data.addColumn('date', 'Date');
      data.addColumn('number', 'Campaigns');

      data.addRows([
        [new Date(2016, 07, 01), 0],
        [new Date(2016, 07, 02), 10],
        [new Date(2016, 07, 03), 23],
        [new Date(2016, 07, 04), 17],
        [new Date(2016, 07, 05), 18],
        [new Date(2016, 07, 06), 9],
        [new Date(2016, 07, 07), 11],
        [new Date(2016, 07, 08), 27],
        [new Date(2016, 07, 09), 33],
        [new Date(2016, 07, 10), 40]
      ]);

      var options = {
        hAxis: {
          gridlines: {
            count: 0
          },
          baselineColor: '#fff',
          gridlineColor: '#fff',
          textPosition: 'none'
        },
        vAxis: {
          gridlines: {
            count: 0
          },
          baselineColor: '#fff',
          gridlineColor: '#fff',
          textPosition: 'none'
        },
        backgroundColor: {
          fill: 'transparent'
        },
        legend: "none",
        height: "100%",
        width: "100%",
        chartArea: {
          height: "80%",
          width: "95%"
        }
      };

      var chart = new google.visualization.AreaChart($("#chartjsChart1")[0]);
      chart.draw(data, options);
    }
  }

  // Top providers chart
  if ($("#chartDonut").length) {
    google.charts.setOnLoadCallback(drawTopProviders);

    function drawTopProviders() {
      var datadonut = google.visualization.arrayToDataTable([
        ['Company', 'Campaign number'],
        ['Work', 11],
        ['Eat', 2],
        ['Commute', 2],
        ['Watch TV', 2]
      ]);

      var optionsdonut = {
        backgroundColor: {
          fill: 'transparent'
        },
        legend: "none",
        height: "100%",
        width: "100%",
        chartArea: {
          height: "85%",
          width: "85%"
        }
      };

      var chartdonut = new google.visualization.PieChart($("#chartDonut")[0]);
      chartdonut.draw(datadonut, optionsdonut);
    }
  }

  // Geneeral metrics chart
  if ($("#chartBar1").length) {
    google.charts.setOnLoadCallback(drawVisualization);

    function drawVisualization() {
      // Some raw data (not necessarily accurate)
      var datageneral = google.visualization.arrayToDataTable([
        ['Month', 'Bolivia', 'Ecuador', 'Madagascar', 'Papua New Guinea', 'Rwanda', 'Average'],
        ['2004/05', 165, 938, 522, 998, 450, 614.6],
        ['2005/06', 135, 1120, 599, 1268, 288, 682],
        ['2006/07', 157, 1167, 587, 807, 397, 623],
        ['2007/08', 139, 1110, 615, 968, 215, 609.4],
        ['2008/09', 136, 691, 629, 1026, 366, 569.6]
      ]);

      var optionsgeneral = {
        hAxis: {
          title: "Date",
          titleTextStyle: {
            italic: false,
            fontName: "IBM Plex Sans"
          }
        },
        vAxis: {
          title: "Earnings",
          titleTextStyle: {
            italic: false,
            fontName: "IBM Plex Sans"
          }
        },
        colors: ['#00cccc', '#fd7e14', '#f10075', '#0168fa', '#5b47fb', '#596882'],
        seriesType: 'bars',
        height: "100%",
        width: "100%",
        chartArea: {
          height: "75%",
          width: "75%"
        }
      };

      var chart = new google.visualization.ComboChart($("#chartBar1")[0]);
      chart.draw(datageneral, optionsgeneral);
    }
  }
});

function board_campaigns_selected(){
  checkbox_selected = $("input:checkbox[id*=checkbox-boardCampaign]:checked");
  board_campaign_ids = [];
  checkbox_selected.each(function() {
    board_campaign_selected = this.value;
    board_campaign_ids.push(board_campaign_selected);
  });
  $("#board_campaign_ids").val(board_campaign_ids);
}

function multiple_update(status){
  board_campaigns_selected();
  $("#content_body").hide();
  $("#placeholderTable").removeClass("d-none");
  $.ajax({
    type:"POST",
    url:  "/board_campaigns/multiple_update",
    dataType: "script",
    data: {board_campaign_ids: $("#board_campaign_ids").val(), status: status},
    success: function(data) {

    },
    error: function(data) {
      alert("Ocurrio un error...");
    }
  });
}

function is_checked()
{
  if(checkbox_selected = $('input:checkbox[id*=checkbox-boardCampaign]:checked').length != 0){
    $('#denied').prop("disabled", false)
    $('#review').prop("disabled", false)
    $('#approved').prop("disabled", false)
  }else{
    $('#denied').prop("disabled", true)
    $('#review').prop("disabled", true)
    $('#approved').prop("disabled", true)
  }
}
