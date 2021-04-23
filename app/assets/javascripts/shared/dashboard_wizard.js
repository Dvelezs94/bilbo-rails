$(document).on('turbolinks:load', function () {
  count = 0;
  if ($('#dashboardWizard').length) {
    // Enable Jquery steps
    $('#dashboardWizard').steps({
      headerTag: 'h3',
      bodyTag: 'section',
      autoFocus: true,
      labels: {
        finish: $('#steps_finish').text(),
        next: $('#steps_next').text(),
        previous: $('#steps_previous').text(),
      },
      titleTemplate: '<span class="number">#index#</span> <span class="title">#title#</span>',
      onFinished: function(event, currentIndex) {
        $('.edit_campaign input[type=submit]').click();
      },
      onStepChanging: function (event, currentIndex, newIndex) {
        if (currentIndex < newIndex) {
          // Step 1 form validation
          if (currentIndex === 0) {
            change_duration();
            var campaignboards = $('#campaign_boards').parsley();
            if (campaignboards.isValid()) {
              return true;
            } else {
              campaignboards.validate();
            }
          }

          if (currentIndex === 1) {
            updateHiddenFieldContent();
            if (validateContent()){
              return true;
            }else {
              show_error($('#error_adding').html());
            }
          }

          // Step 2 form validation
          if (currentIndex === 2) {
            //this is for count the Schedules added in campaign for hour
            if ($('#add_schedule').length) {
              if (
                $(document.querySelectorAll('.days_of_week:not(.noValid)'))
                  .length > 0
              ) {
                count = $(
                  document.querySelectorAll('.days_of_week:not(.noValid)')
                ).length;
              }
              for(var i = 0; i<count; i++){
                // set Event listeners to each hour_row and update the fields that are necessary
                $($("[hour_row]")[i]).on('keyup change paste', function(e){ updateOnChanges(e,this);});
                updateBudget(i);
              }
            }
            if ($('#timePicker').length) {
              var d = new Date(),
                h = d.getHours(),
                m = d.getMinutes();
              if (h < 10) h = '0' + h;
              if (m < 10) m = '0' + m;

              $('#timePicker').attr({
                value: h + ':' + m,
              });
            }
            calculateMaxImpressions();
            if ($('#impressions').length) {
              calculateImpressions();
            }
          }

          if (currentIndex === 2) {
            if ($('#add_schedule').length) {
              var campaignstartsat = $('#campaign_starts_at').parsley();
              var campaignendsat = $('#campaign_ends_at').parsley();
              if ($('#date_campaign').prop('checked')) {
                if (count == 0) {
                  show_error($('#button_schedule_error_message').html());
                  return false;
                } else {
                  if (
                    validatesPerHour() &&
                    campaignstartsat.isValid() &&
                    campaignendsat.isValid() &&
                    count > 0
                  ) {
                    return true;
                  } else {
                    campaignstartsat.validate();
                    campaignendsat.validate();
                    //validatesPerHour();
                    return false;
                  }
                }
              } else {
                if (count == 0) {
                  show_error($('#button_schedule_error_message').html());
                  return false;
                } else {
                  return validatesPerHour();
                }
              }
            }

            if ($('#imp_minute').length) {
              var campaignimpressionminute = $('#imp_minute').parsley();
              var campaignminutes = $('#campaign_minutes').parsley();
              var campaignstartsat = $('#campaign_starts_at').parsley();
              var campaignendsat = $('#campaign_ends_at').parsley();

              if ($('#date_campaign').prop('checked')) {
                if (
                  campaignstartsat.isValid() &&
                  campaignendsat.isValid() &&
                  campaignimpressionminute.isValid() &&
                  campaignminutes.isValid()
                ) {
                  return true;
                } else {
                  campaignstartsat.validate();
                  campaignendsat.validate();
                  campaignimpressionminute.validate();
                  campaignminutes.validate();
                  return false;
                }
              } else {
                if (
                  campaignimpressionminute.isValid() &&
                  campaignminutes.isValid()
                ) {
                  return true;
                } else {
                  campaignimpressionminute.validate();
                  campaignminutes.validate();
                  return false;
                }
              }
            }
            // check if the user set a minimum of 50 per board
            if ($('#campaign_budget').length) {
              var campaignbudget = $('#campaign_budget').parsley();
              var campaignstartsat = $('#campaign_starts_at').parsley();
              var campaignendsat = $('#campaign_ends_at').parsley();
              if ($('#date_campaign').prop('checked')) {
                if (
                  parseInt($('#campaign_budget').val().replace(',', '')) /
                    parseInt($('#boards_counter').html()) <
                  50
                ) {
                  show_error($('#budget_error_message').html());
                  return false;
                }

                if (
                  campaignbudget.isValid() &&
                  campaignstartsat.isValid() &&
                  campaignendsat.isValid()
                ) {
                  return true;
                } else {
                  campaignbudget.validate();
                  campaignstartsat.validate();
                  campaignendsat.validate();
                  return false;
                }
              }
              if (
                parseInt($('#campaign_budget').val().replace(',', '')) /
                  parseInt($('#boards_counter').html()) >=
                50
              ) {
                return true;
              } else {
                show_error($('#budget_error_message').html());
                return false;
              }
            }
          }

          if (currentIndex === 3) {
            var campaign_link = $('#campaign_link').parsley();
            if (campaign_link.isValid()) {
              return true;
            } else {
              campaign_link.validate();
            }
          }
          // Always allow step back to the previous step even if the current step is not valid.
        } else {
          return true;
        }

      },
      onStepChanged: function (event, currentIndex, priorIndex) {
        // update summary on map change
        if (priorIndex === 0) {
          content_info();
          // update summary on budget and date change
          $('#bilbosAddress').empty();
          $('#selected_boards option:not(:eq(0))').each(function () {
            $('#bilbosAddress').append('<li>' + $(this).text() + '</li>');
            // change size of preview in summary
            $('#parent-carousel').width(
              $('#aspect_ratio_select option:selected').attr('new-width')
            );
            $('#parent-carousel').height(
              $('#aspect_ratio_select option:selected').attr('new-height')
            );
          });
          $('#bilbosNum').text($('#bilbosAddress li').length);
          if ($('#impressions').length == 1)
            $('#impressions')[0].style.width =
              ($('#campaign_budget')[0].value.length + 5) * 8 + 'px';
        } else if (priorIndex === 2) {
          showHideCarouselContent();
          $('#perMinute').text($('#imp_minute').val());
          $('#perMinuteEnd').text($('#campaign_minutes').val());
          make_summary_selected_hours();
          make_spend_summary_selected_hours();
          // $('#impPerHour').text($('#impressionsPerHour').val());
          // $('#timeStart').text($('#timePickerStart').val());
          // $('#timeEnd').text($('#timePickerEnd').val());
          $('#dailyBudget').text($('#campaign_budget').val());
          if ($('#date_campaign').prop('checked')) {
            $('#campaignStarts').text($('#campaign_starts_at').val());
            $('#campaignEnds').text($('#campaign_ends_at').val());
          } else {
            $('#campaignStarts').text('');
            $('#campaignEnds').text('');
          }
        }
      },
    });
    // End Jquery steps

    // calculate budget when input is updated
    $('#campaign_budget').keyup(function() {
      $("#impressions")[0].style.width = (this.value.length + 5) * 8 + 'px';
      calculateImpressions();
    });
    if ($('#impressions').length) {
      $('#impressions').on('keyup change paste', function () {
        this.style.width = (this.value.length + 5) * 8 + 'px';
        calculateBudget(this.value);
      });
      $('#impressions').width(($('#impressions').val().length + 5) * 8 + 'px');
    }

    // function to calculate impressions
    function calculateImpressions(testBudget = null) {
      max_estimated_impressions = 0;
      var changed_for_max_imp = false;
      total_budget = (testBudget != null) ? testBudget : $('#campaign_budget').val();
      if (typeof(total_budget) == "string") total_budget = total_budget.replace(',', ''); // removes comma from number given by user because parseFLoat thinks its decimal after comma
      budget_per_bilbo = parseFloat(total_budget) / ($('#selected_boards option:not(:eq(0))').length);
      $('#selected_boards option:not(:eq(0))').each(function() {
        cycles = parseInt($(".wizard_selected_ad").find(".ad-duration").data("duration")) || parseInt($(this).data('cycle-duration'));
        bilbo_max_impressions = parseInt($(this).data('max-impressions') * 10 / cycles)
        current_impressions_for_bilbo = parseInt(budget_per_bilbo / ($(this).data('price') * cycles)) || 0;
        if (current_impressions_for_bilbo > bilbo_max_impressions){
          max_estimated_impressions+= bilbo_max_impressions;
          changed_for_max_imp = true;
          if (testBudget == null) {
            calculateBudget(1000000);
            return false;
          }
        } else {
          max_estimated_impressions+=current_impressions_for_bilbo;
        }
      });
      if (testBudget == null && !changed_for_max_imp) $('#impressions').val(max_estimated_impressions);
      return [max_estimated_impressions,changed_for_max_imp];
    }
    function calculateBudget(desired_impressions) {
      if (desired_impressions == "") return true;
      max_boards_impr = parseInt($('#max_impressions').val());
      if (desired_impressions > max_boards_impr) desired_impressions = max_boards_impr;
      budget = 0;
      var changed_for_max_imp;
      var obtained_impressions;
      var final_impressions;
      for (var b = 256.0; b >= 0.49; b /= 2) {
        while(true){
          let result = calculateImpressions(budget+b);
          obtained_impressions = result[0];
          changed_for_max_imp = result[1];
          if (changed_for_max_imp || obtained_impressions > desired_impressions) break;
          budget+=b;
          final_impressions = obtained_impressions;
        }
      }
      //when we select multiple boards, the lower arrow cant select some numbers, so this is a fix so we "jump" that numbers.
      if (desired_impressions < max_boards_impr && final_impressions != desired_impressions && window.impressions < desired_impressions) {
        var b = 0.5;
        while(true){
          let result = calculateImpressions(budget+b);
          obtained_impressions = result[0];
          changed_for_max_imp = result[1];
          if (changed_for_max_imp || obtained_impressions > max_boards_impr) break;
          if (obtained_impressions != final_impressions){
            budget+=b;
            final_impressions = obtained_impressions;
            break;
          }
          b+=0.5;
        }
      }
      $("#campaign_budget").val(budget);
      $('#impressions').val(final_impressions);
      window.impressions = final_impressions;
      return true;
    }

    function updateOnChanges(e, obj) {
      if ($('#add_schedule').length) {
        for (var j = 0; j < count; j++) {
          //update the budget in case the impressions are modified
          if (obj == $("[hour_row]")[j]) {
            if (e["target"]["id"].startsWith("campaign_impression_hours_attributes")) {
              if (e["target"]["id"].endsWith("imp")) {
                updateBudget(j);
                break;
              }
            } else if (e["target"]["id"] == "") {
              //update the impressions in case the budget is modified
              budget = $($("[hour_row]").find('.budget')[j]).val();
              var imp = computeImpressionsPerHour(budget);
              $($("[hour_row]")[j]).find('.impressionsPerHour').val(imp);
              break;
            }
          }
        }
      }
      return;
    }

    // calculate max impressions sum of all boards
    function calculateMaxImpressions() {
      max_impr = 0;
      $('#selected_boards option:not(:eq(0))').each(function () {
        cycles =
          parseInt(
            $('.wizard_selected_ad').find('.ad-duration').data('duration')
          ) || parseInt($(this).data('cycle-duration'));
        max_impr +=
          parseInt(($(this).data('max-impressions') * 10) / cycles) || 0;
      });
      $('#max_impressions').val(max_impr);
    }

    // calculate board prints
    function getadwizard() {
      $.ajax({
        url: '/ads/wizard_fetch',
        dataType: 'script',
        data: {
          ad_id: $('#campaign_ad_id').val(),
        },
      });
    }

    $('#date_campaign').click(function () {
      $('#campaign_starts_at').prop('required', true);
      $('#campaign_ends_at').prop('required', true);
      $('#campaign_starts_at')
        .datepicker({
          minDate: 0,
          dateFormat: 'yy-mm-dd',
        })
        .val();
      $('#campaign_ends_at')
        .datepicker({
          minDate: 1,
          dateFormat: 'yy-mm-dd',
        })
        .val();
    });

    $('#ongoing_campaign').click(function () {
      $('#campaign_starts').prop('required', false);
      $('#campaign_ends').prop('required', false);
    });
    // End Datepick

    // Toggle Datepick radio buttons
    $('#campaign_starts_at').prop('disabled', true);
    $('#campaign_ends_at').prop('disabled', true);
    $('input[type=radio]').click(function () {
      if ($(this).prop('id') == 'date_campaign') {
        $('#campaign_starts_at').prop('disabled', false);
        $('#campaign_ends_at').prop('disabled', false);
      } else {
        $('#campaign_starts_at').prop('disabled', true);
        // $("#campaign_starts_at").val("")
        $('#campaign_ends_at').prop('disabled', true);
        // $("#campaign_ends_at").val("")
      }
    });

    if ($('#date_campaign').prop('checked')) {
      $('#campaign_starts_at').prop('disabled', false);
      $('#campaign_ends_at').prop('disabled', false);
    }
    // End toggle

    select_ad();
    // end choose ad

    $("#add_schedule").on('click', function(){
      setTimeout(function(){
        $($("[hour_row]")[count-1]).on('keyup change paste', function(e){ updateOnChanges(e,this);});
      },100);
    });

    function updateBudget(x){
      impressions = $($("[hour_row]")[x]).find('.impressionsPerHour').val();
      $($("[hour_row]").find('.budget')[x]).val(computeBudget(impressions))
    }

    function computeImpressionsPerHour(budget){
      price = 0;
      $('#selected_boards option:not(:eq(0))').each(function() {
        cycles = parseInt($(".wizard_selected_ad").find(".ad-duration").data("duration")) || parseInt($(this).data('cycle-duration'));
        price += $(this).data('price') * cycles;
      });
      impressions = parseInt(budget/price);
      max_boards_impr = parseInt($('#max_impressions').val());
      if (impressions > max_boards_impr) impressions = max_boards_impr;
      return impressions;
    }

    function computeBudget(impressions){
      total_price = 0
      $('#selected_boards option:not(:eq(0))').each(function() {
        cycles = parseInt($(".wizard_selected_ad").find(".ad-duration").data("duration")) || parseInt($(this).data('cycle-duration'));
        board_price = impressions * $(this).data('price') * cycles;
        total_price += board_price;
      });
      return Math.ceil(total_price*2)/2; //Round the budget to the nearest multiple of 0.5 that is higher than the value found
    }

  }
});


function make_summary_selected_hours() {
  hour_rows = $('[hour_row]');
  partial = $('#hours_summary');
  $('.current_row_hours').remove();
  $.each(hour_rows, function (index, elem) {
    new_partial = partial.clone();
    new_partial.removeClass('d-none');
    new_partial.addClass('current_row_hours');
    new_partial.removeAttr('id');
    dayOfWeek = new_partial.find('.dayOfWeek');
    impPerHour = new_partial.find('.impPerHour');
    timeStart = new_partial.find('.timeStart');
    timeEnd = new_partial.find('.timeEnd');
    dayOfWeek.text(
      $(elem).find('.days_of_week:not(.noValid) :selected').html() + ' - '
    );
    impPerHour.text($(elem).find('.impressionsPerHour:not(.noValid)').val());
    timeStart.text($(elem).find('.timePickerStart:not(.noValid)').val());
    timeEnd.text($(elem).find('.timePickerEnd:not(.noValid)').val());
    if (
      $(elem).find('.days_of_week:not(.noValid) :selected').val() !=
        undefined &&
      $(elem).find('.impressionsPerHour:not(.noValid)').val() != undefined &&
      $(elem).find('.timePickerStart:not(.noValid)').val() != undefined &&
      $(elem).find('.days_of_week:not(.noValid) :selected').val() != undefined
    ) {
      $('#current_row_hours').append(new_partial);
    }
  });
}
function make_spend_summary_selected_hours(){
  hour_rows = $("[hour_row]");
  partial = $("#spend_summary");
  $(".current_spend").remove();
  daysOfWeek= ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
  $.each(daysOfWeek, function(index, day) {
    new_partial = partial.clone();
    new_partial.removeClass("d-none");
    new_partial.addClass("current_spend");
    new_partial.removeAttr("id");
    dayOfWeek = new_partial.find(".dayOfWeek");
    money = new_partial.find(".money");
    total = 0;
    $.each(hour_rows, function(index2, hr) {
      if ($(hr).find('.days_of_week:not(.noValid) :selected').val() != undefined &&
        $(hr).find('.impressionsPerHour:not(.noValid)').val() != undefined && $(hr).find('.timePickerStart:not(.noValid)').val() != undefined &&
        $(hr).find('.days_of_week:not(.noValid) :selected').val() != undefined &&
        $(hr).find("select.days_of_week option:selected").val() == day || $(hr).find("select.days_of_week option:selected").val() == "everyday") {
        hr_budget = parseFloat($(hr).find(".budget").val());
        total += hr_budget;
      }
    });
    day_name = hour_rows.find("select.days_of_week option[value="+ day +"]").html();
    dayOfWeek.append(day_name+ " - $");
    money.append(total );
    $("#current_spend").append(new_partial);
  });
}

function buttonCount() {
  //when user clicks button add schedule in hourly campaign count goes up is for validate the user click the button
  count += 1;
}

function buttonSubstraction() {
  //when user clicks button trash in hourly campaign count goes down and is for validate the user have adding schedules
  setTimeout(function () {
    //Check that all fields are hidden for nested fields and add the class noValid
    for (
      var i = 0;
      i < $(document.querySelectorAll('.nested-fields')).length;
      i++
    ) {
      if (
        document.querySelectorAll('.nested-fields')[i].style.display == 'none'
      ) {
        $(document.querySelectorAll('.nested-fields')[i]).addClass('noValid');
        for (
          var y = 0;
          y < $(document.querySelectorAll('.noValid div select')).length;
          y++
        ) {
          $(document.querySelectorAll('.noValid div select')[y]).addClass(
            'noValid'
          );
        }
        for (
          var x = 0;
          x < $(document.querySelectorAll('.noValid div input')).length;
          x++
        ) {
          $(document.querySelectorAll('.noValid div input')[x]).addClass(
            'noValid'
          );
        }
      }
    }
  }, 100);
  count -= 1;
}

//function that validate that all fields are filled in the campaign per hour
function validatesPerHour() {
  // variable that saves if is true that all fields are filled or not
  var valid;
  //loop that checks each of the fields that do not have the class noValid
  for (var i = 0; i < count; i++) {
    daysofweek = $(
      document.querySelectorAll('.days_of_week:not(.noValid)')[i]
    ).parsley();
    impressionsperhour = $(
      document.querySelectorAll('.impressionsPerHour:not(.noValid)')[i]
    ).parsley();
    timestart = $(
      document.querySelectorAll('.timePickerStart:not(.noValid)')[i]
    ).parsley();
    timeend = $(
      document.querySelectorAll('.timePickerEnd:not(.noValid)')[i]
    ).parsley();
    if (
      daysofweek.isValid() &&
      impressionsperhour.isValid() &&
      timestart.isValid() &&
      timeend.isValid() &&
      count > 0
    ) {
      valid = true;
    } else {
      daysofweek.validate();
      impressionsperhour.validate();
      timestart.validate();
      timeend.validate();
      valid = false;
    }
  }
  return valid;
}


function content_info(){
  boards = $("#campaign_boards");
  if(boards.length > 1){
    selected_boards = boards.val().substring(1);
  }else{
    selected_boards = boards.val();
  }
  $.ajax({
    url:  "/campaigns/"+$("#campaign_id").val()+"/get_boards_content_info",
    dataType: "script",
    data: {selected_boards: selected_boards},
    success: function(data) {
    },
    error: function(data) {
      alert("Oops.. Ocurrio un error..");
    }
  });
}

function append_content(){
  $('#modalContent').modal('hide');
  board_slug = $('#slug-board').val();
  content_board = $('#'+$('#slug-board').val());
  content_board.val("");
  checkbox_selected = $('input[type="checkbox"]:checked');
  content_ids = [];
  $('input[type="checkbox"]:checked').each(function() {
     content = this.id.split("pickContent");
     content_ids.push(content[1]);
  });
  cont_ids = content_ids.toString().replace(/,/g , " ");
  content_board.val(cont_ids);
  showContent(content_board, board_slug);
}



function showContent(content_board, board_slug){
  $.ajax({
    url:  "/contents_board_campaign/get_selected_content",
    dataType: "script",
    data: {selected_contents: content_board.val(), board_slug: board_slug, campaign: $("#campaign_id").val()},
    success: function(data) {
    },
    error: function(data) {
      alert("Oops.. Ocurrio un error..");
    }
  });
}

function delete_content(content_id, board_slug){
  //find in the front-end the content to delete
  $('#content-delete-'+content_id+"-"+board_slug).remove();
  $('#content-'+content_id+"-"+board_slug).remove();
  $('#wizard-content-'+content_id+"-"+board_slug).remove();
  //delete in the hiddenfield the contents
  var arr = $('#'+board_slug).val().split(" ");
    for( var i = 0; i < arr.length; i++){
        if ( arr[i] === content_id) {
            arr.splice(i, 1);
            i--;
        }
    }
    $('#'+board_slug).val(arr.toString().replace(/,/g , " "));
}

function updateHiddenFieldContent(){
  contents_selected = $('input*[id*=bilbo-]');
  var content_board_campaign = {}
  var i;
  for (i = 0; i < contents_selected.length; i++) {
    x = $("#"+contents_selected[i].id)
    content_board_campaign[contents_selected[i].id] = x.val()
  }
  $("#content_ids").val(JSON.stringify(content_board_campaign))
}

function validateContent(){
  contents = $("#content_ids");
  var i;
  validation = true;
  for (i = 0; i < contents.val().split(",").length; i++) {
    if ((contents.val().split(",")[i].split(":")[1] === '""') || (contents.val().split(",")[i].split(":")[1] === '""}')){
      validation = false;
      break;
    }else{
      validation = true;
    }
  }
  return validation;
}

function showHideCarouselContent(){
  board = $("#aspect_ratio_select").val()
  wizard = $('div*[id*=wizard-div]');
  wizard.each(function () {
      $(this).hide();
      });
  $("#wizard-div-"+board).show();

}


function append_content_to_carousel_wizard(){
  board_content_selected = $('input*[id*=bilbo-]');
  board_content_selected.each(function () {
    board_slug = this.id;
    content_board = $("#" + board_slug);
    showContent(content_board, board_slug);
      showHideCarouselContent();
  });

}

function change_duration(){
  campaign_bilbo_duration = $("#campaign_bilbo_duration");
  campaign_bilbo_duration.change(function() {
  replace_duration();
});
}

function replace_duration(){
  campaign_bilbo_duration = $("#campaign_bilbo_duration");
$('td*[id*=bilbo_duration]').each(function(){
  bilbo_duration_change = $(this);
  bilbo_duration_change.text(bilbo_duration_change.text().replace(bilbo_duration_change.text().split(" ")[0], campaign_bilbo_duration.val()));  });
}
