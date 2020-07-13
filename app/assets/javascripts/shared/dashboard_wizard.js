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
          calculateMaxImpressions();
          calculatebudget();
          var campaignboards = $('#campaign_boards').parsley();

          if(campaignboards.isValid()) {
            return true;
          } else {
            campaignboards.validate();
          }
        }

        if(currentIndex === 2) {
          // check if the user set a minimum of 50 per board
          if ( (parseInt($('#campaign_budget').val().replace(',','')) / parseInt($('#boards_counter').html())) >= 50 ) {
            return true
          } else {
            show_error($("#budget_error_message").html());
            return false
          }
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
      // update summary on ads change
      if (priorIndex === 0) {
        $("#adName").text($(".wizard_selected_ad .card-body").text());
        getadwizard();
        // update summary on map change
      } else if ( priorIndex === 1) {
        // update summary on budget and date change
        $('#bilbosAddress').empty()
        $("#selected_boards option:not(:eq(0))").each(function() {
          $("#bilbosAddress").append('<li>'+$(this).text()+'</li>');
        });
        $("#bilbosNum").text($("#bilbosAddress li").length)
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

    // calculate budget when input is updated
    $("#campaign_budget").keyup(function(){
      calculatebudget();
    });
    $("#impressions").on("keyup", function() {
      this.style.width = ((this.value.length + 5) * 8) + 'px';
      calculateInvbudget(this.value);
    });
    $("#impressions").width( ($("#impressions").val().length +5 )*8+"px")
    // function to calculate impressions
    function calculatebudget() {
      sum = 0
      $("#selected_boards option:not(:eq(0))").each(function() {
        sum +=  $(this).data('price') || 0;
        avg = sum/$("#selected_boards option:not(:eq(0))").length
      });
      // max impressions based on the budget
      maximum_impressions = Math.round(parseFloat($("#campaign_budget").val().replace(',',''))/avg)
      // max possible impressions of bilbos
      max_boards_impr = parseInt($("#max_impressions").val());
      if (maximum_impressions > max_boards_impr) {
        $("#impressions").val(max_boards_impr);
      } else {
        $("#impressions").val(maximum_impressions);
      }
    }
    function calculateInvbudget(maximum_impressions) {
      sum = 0
      $("#selected_boards option:not(:eq(0))").each(function() {
        sum +=  $(this).data('price') || 0;
        avg = sum/$("#selected_boards option:not(:eq(0))").length
      });
      // if the impressions are greater than max possible impressions of bilbos, take the max posible
      max_boards_impr = parseInt($("#max_impressions").val());
      if (maximum_impressions > max_boards_impr) {
        maximum_impressions = max_boards_impr;
        $("#impressions").val(max_boards_impr);
      }
      // get the budget
      impressions_budget = Math.round(parseFloat(maximum_impressions*avg));
      $("#campaign_budget").val(impressions_budget);
    }


    // calculate max impressions sum of all boards
    function calculateMaxImpressions() {
      max_impr = 0
      $("#selected_boards option:not(:eq(0))").each(function() {
        max_impr += $(this).data('max-impressions') || 0;
      });
      $("#max_impressions").val(max_impr);
    }

    // calculate board prints
    function getadwizard() {
      $.ajax({
        url:  "/ads/wizard_fetch",
        dataType: "script",
        data: {ad_id: $("#campaign_ad_id").val()}
      });

    }

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
