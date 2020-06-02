$(document).on('turbolinks:load', function() {
  if ($("#dashboardWizard").length) {
    // Enable Jquery steps
    $('#dashboardWizard').steps({
      headerTag: 'h3',
      bodyTag: 'section',
      autoFocus: true,
      titleTemplate: '<span class="number">#index#</span> <span class="title">#title#</span>',
      onFinished: function (event, currentIndex) {
        $(".edit_campaign").submit();
      },
      onStepChanging: function (event, currentIndex, newIndex) {
      if(currentIndex < newIndex) {
        // Step 1 form validation
        if(currentIndex === 0) {
          var campaignadid = $('#campaign_ad_id').parsley();
          if(campaignadid.isValid()) {
            return true;
          } else { campaignadid.validate(); }
        }


        // Step 2 form validation
        if(currentIndex === 1) {
          var campaignboards = $('#campaign_boards').parsley();

          if(campaignboards.isValid()) {
            return true;
          } else {
            campaignboards.validate();
          }
        }

        if(currentIndex === 2) {
          var campaignbudget = $('#campaign_budget').parsley();
          var campaignstartsat = $('#campaign_starts_at').parsley();
          var campaignendsat = $('#campaign_ends_at').parsley();
          if ($("#date_campaign").prop("checked")){
            if(campaignbudget.isValid() && campaignstartsat.isValid() && campaignendsat.isValid()) {
              return true;
            } else {
              campaignbudget.validate();
              campaignstartsat.validate();
              campaignendsat.validate();
            }
          }
          else {
            if(campaignbudget.isValid()) {
              return true;
            } else {
              campaignbudget.validate();
            }
          }
        }
      // Always allow step back to the previous step even if the current step is not valid.
      } else { return true; }
    },
    onStepChanged: function (event, currentIndex, priorIndex) {
      // update summary on map change
      if (priorIndex === 0) {
        $('#bilbosAddress').empty()
        $("#selected_boards option:not(:eq(0))").each(function() {
          $("#bilbosAddress").append('<li>'+$(this).text()+'</li>');
        });
        $("#bilbosNum").text($("#bilbosAddress li").length)
        // update summary on ads change
      } else if ( priorIndex === 1) {
        $("#adName").text($(".wizard_selected_ad .card-body").text());
        // update summary on budget and date change
      } else if (priorIndex === 2) {
        $("#dailyBudget").text($("#campaign_budget").val())
        if ($("#date_campaign").prop("checked")){
          $("#campaignStarts").text($("#campaign_starts_at").val());
          $("#campaignEnds").text($("#campaign_ends_at").val());
        } else {
          $("#campaignStarts").text("");
          $("#campaignEnds").text("");
        }
      }
    }
  });
    // End Jquery steps
    $("#campaign_budget").keyup(function(){
      sum = 0
      $("#selected_boards option:not(:eq(0))").each(function() {
        sum +=  $(this).data('price') || 0;
        avg = sum/$("#selected_boards option:not(:eq(0))").length
      });
      console.log(sum);
      maximum_impressions = Math.round(parseFloat($("#campaign_budget").val().replace(',',''))/avg)
      $("#impressions").text(maximum_impressions);
    });
    // calculate board prints


    $("#date_campaign").click(function() {
      $("#campaign_starts_at").prop('required', true);
      $("#campaign_ends_at").prop('required', true);
      $('#campaign_starts_at').datepicker({
        dateFormat: 'yy-mm-dd'
      }).val();
      $('#campaign_ends_at').datepicker({
        dateFormat: 'yy-mm-dd'
      }).val();
    });

    $("#ongoing_campaign").click(function() {
      $("#campaign_starts_at").prop('required', false);
      $("#campaign_ends_at").prop('required', false);
    });
    // End Datepick

    // Toggle Datepick radio buttons
     $("#campaign_starts_at").prop('disabled', true);
     $("#campaign_ends_at").prop('disabled', true);
     $('input[type=radio]').click(function(){
       if($(this).prop('id') == "date_campaign"){
         $("#campaign_starts_at").prop('disabled', false);
         $("#campaign_ends_at").prop('disabled', false);
       }else{
         $("#campaign_starts_at").prop('disabled', true);
         // $("#campaign_starts_at").val("")
         $("#campaign_ends_at").prop('disabled', true);
         // $("#campaign_ends_at").val("")
       }
     });


     if ($("#date_campaign").prop("checked")){
       $("#campaign_starts_at").prop('disabled', false);
       $("#campaign_ends_at").prop('disabled', false);
     }
    // End toggle

    // choose ad in wizard
    $(".card-ad-link").click(function(e){
      e.preventDefault();
      $(".wizard_selected_ad").removeClass("wizard_selected_ad");
      $(this).find("div:first-child > .card").addClass("wizard_selected_ad");
      $("#campaign_ad_id").val($(this).attr("id"));
    });

    if ($("#campaign_ad_id").val()){
      var selected_ad_id = $("#campaign_ad_id").val()
      var selected_ad = ($("#" + selected_ad_id))
      selected_ad.find("div:first-child > .card").addClass("wizard_selected_ad");
    }
    // end choose ad
  }
});
