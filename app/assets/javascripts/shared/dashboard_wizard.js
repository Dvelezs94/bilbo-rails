$(document).on('turbolinks:load', function() {
  count = 0;
  if ($('#dashboardWizard').length) {
    // Enable Jquery steps
    $('#dashboardWizard').steps({
      headerTag: 'h3',
      bodyTag: 'section',
      autoFocus: true,
      titleTemplate: '<span class="number">#index#</span> <span class="title">#title#</span>',
      onFinished: function(event, currentIndex) {
        $('.edit_campaign input[type=submit]').click();
      },
      onStepChanging: function(event, currentIndex, newIndex) {
        if (currentIndex < newIndex) {
          // Step 1 form validation
          if (currentIndex === 0) {
            var campaignadid = $('#campaign_ad_id').parsley();
            if (campaignadid.isValid()) {
              return true;
            } else {
              campaignadid.validate();
            }
          }

          // Step 2 form validation
          if (currentIndex === 1) {
            //this is for count the Schedules added in campaign for hour
            if ($('#add_schedule').length) {
              if ($(document.querySelectorAll('.days_of_week:not(.noValid)')).length > 0) {
                count = $(document.querySelectorAll('.days_of_week:not(.noValid)')).length;
              }
            }
            if ($('#timePicker').length) {
              var d = new Date(),
                h = d.getHours(),
                m = d.getMinutes();
              if (h < 10) h = '0' + h;
              if (m < 10) m = '0' + m;

              $('#timePicker').attr({
                value: h + ':' + m
              });
            }
            calculateMaxImpressions();
            if ($('#impressions').length) {
              calculatebudget();
            }
            var campaignboards = $('#campaign_boards').parsley();

            if (campaignboards.isValid()) {
              return true;
            } else {
              campaignboards.validate();
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
                  if (validatesPerHour() &&
                    campaignstartsat.isValid() &&
                    campaignendsat.isValid() &&
                    count > 0) {
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

            if ($("#imp_minute").length) {
              var campaignimpressionminute = $('#imp_minute').parsley();
              var campaignminutes = $('#campaign_minutes').parsley();
              var campaignstartsat = $('#campaign_starts_at').parsley();
              var campaignendsat = $('#campaign_ends_at').parsley();

              if ($('#date_campaign').prop('checked')) {
                if (campaignstartsat.isValid() && campaignendsat.isValid() && campaignimpressionminute.isValid() &&
                  campaignminutes.isValid()) {
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

          // Always allow step back to the previous step even if the current step is not valid.
        } else {
          return true;
        }
      },
      onStepChanged: function(event, currentIndex, priorIndex) {
        // update summary on ads change
        if (priorIndex === 0) {
          $('#adName').text($('.wizard_selected_ad .card-body').text());
          getadwizard();
          // update summary on map change
        } else if (priorIndex === 1) {
          // update summary on budget and date change
          $('#bilbosAddress').empty();
          $('#selected_boards option:not(:eq(0))').each(function() {
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
          if ($("#impressions").length == 1) $("#impressions")[0].style.width = ($('#campaign_budget')[0].value.length + 5) * 8 + 'px';
        } else if (priorIndex === 2) {
          $('#perMinute').text($('#imp_minute').val());
          $('#perMinuteEnd').text($('#campaign_minutes').val());
          make_summary_selected_hours();
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
      calculatebudget();
    });
    if ($('#impressions').length) {
      $('#impressions').on('keyup change paste', function() {
        this.style.width = (this.value.length + 5) * 8 + 'px';
        calculateInvbudget(this.value);
      });
      $('#impressions').width(($('#impressions').val().length + 5) * 8 + 'px');
      // function to calculate impressions
<<<<<<< HEAD
    }
    function calculatebudget(testBudget = null) {
      total_impressions = 0;
      total_budget = (testBudget != null)? testBudget : $('#campaign_budget').val();
      if(typeof(total_budget) == "string") total_budget = total_budget.replace(',', ''); // removes comma from number given by user because parseFLoat thinks its decimal after comma
      budget_per_bilbo = total_budget/($('#selected_boards option:not(:eq(0))').length);
      $('#selected_boards option:not(:eq(0))').each(function () {
        cycles = parseInt($(".wizard_selected_ad").find(".ad-duration").data("duration")) || parseInt($(this).data('cycle-duration'));
        bilbo_max_impressions = parseInt($(this).data('max-impressions')*10/cycles)
        current_impressions_for_bilbo = parseInt(budget_per_bilbo/($(this).data('price')*cycles)) || 0;
        total_impressions += (current_impressions_for_bilbo > bilbo_max_impressions)? bilbo_max_impressions : current_impressions_for_bilbo
=======
      function calculatebudget() {
        sum = 0;
        $('#selected_boards option:not(:eq(0))').each(function() {
          sum += $(this).data('price') || 0;
          avg = sum / $('#selected_boards option:not(:eq(0))').length;
        });
        // max impressions based on the budget
        maximum_impressions = Math.floor(
          parseFloat($('#campaign_budget').val().replace(',', '')) / avg
        );
        // max possible impressions of bilbos
        max_boards_impr = parseInt($('#max_impressions').val());
        if (maximum_impressions > max_boards_impr) {
          $('#impressions').val(max_boards_impr);
        } else {
          $('#impressions').val(maximum_impressions);
        }
      }
    }

    function calculateInvbudget(maximum_impressions) {
      sum = 0;
      $('#selected_boards option:not(:eq(0))').each(function() {
        sum += $(this).data('price') || 0;
        avg = sum / $('#selected_boards option:not(:eq(0))').length;
>>>>>>> c22789ff50918d44bbca92d7fe7b898a36d0dbce
      });
      // max possible impressions of bilbos
      max_boards_impr = parseInt($('#max_impressions').val());
      if (total_impressions > max_boards_impr) total_impressions = max_boards_impr;
      $('#impressions').val(total_impressions);
      return total_impressions;
    }
    function calculateInvbudget(desired_impressions) {
      if(desired_impressions == "") return true;
      max_boards_impr = parseInt($('#max_impressions').val());
      if (desired_impressions > max_boards_impr) desired_impressions = max_boards_impr;
      budget = 0
      var i;
      for(i=0; i< 2000;i++) {
        obtained_impressions = calculatebudget(budget)
        if (obtained_impressions==desired_impressions){
          $("#campaign_budget").val(budget);
          return true;
        }
        else if(obtained_impressions>desired_impressions) {
          budget -= 0.5;
        }
        else {
          budget+=50;
        }
      }
    }

    // calculate max impressions sum of all boards
    function calculateMaxImpressions() {
      max_impr = 0;
<<<<<<< HEAD
      $('#selected_boards option:not(:eq(0))').each(function () {
        cycles = parseInt($(".wizard_selected_ad").find(".ad-duration").data("duration")) || parseInt($(this).data('cycle-duration'));
        max_impr += parseInt($(this).data('max-impressions')*10/cycles) || 0;
=======
      $('#selected_boards option:not(:eq(0))').each(function() {
        max_impr += $(this).data('max-impressions') || 0;
>>>>>>> c22789ff50918d44bbca92d7fe7b898a36d0dbce
      });
      $('#max_impressions').val(max_impr);
    }

    // calculate board prints
    function getadwizard() {
      $.ajax({
        url: '/ads/wizard_fetch',
        dataType: 'script',
        data: {
          ad_id: $('#campaign_ad_id').val()
        },
      });
    }

    $('#date_campaign').click(function() {
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

    $('#ongoing_campaign').click(function() {
      $('#campaign_starts_at').prop('required', false);
      $('#campaign_ends_at').prop('required', false);
    });
    // End Datepick

    // Toggle Datepick radio buttons
    $('#campaign_starts_at').prop('disabled', true);
    $('#campaign_ends_at').prop('disabled', true);
    $('input[type=radio]').click(function() {
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

    // choose ad in wizard
    $('.card-ad-link').click(function(e) {
      e.preventDefault();
      $('.wizard_selected_ad').removeClass('wizard_selected_ad');
      $(this).find('div:first-child > .card').addClass('wizard_selected_ad');
      $('#campaign_ad_id').val($(this).attr('id'));
    });

    if ($('#campaign_ad_id').val()) {
      var selected_ad_id = $('#campaign_ad_id').val();
      var selected_ad = $('#' + selected_ad_id);
      selected_ad
        .find('div:first-child > .card')
        .addClass('wizard_selected_ad');
    }
    // end choose ad
  }
});

function make_summary_selected_hours() {
  hour_rows = $("[hour_row]");
  partial = $("#hours_summary");
  $(".current_row_hours").remove();
  $.each(hour_rows, function(index, elem) {
    new_partial = partial.clone();
    new_partial.removeClass("d-none");
    new_partial.addClass("current_row_hours");
    new_partial.removeAttr("id");
    dayOfWeek = new_partial.find(".dayOfWeek");
    impPerHour = new_partial.find(".impPerHour");
    timeStart = new_partial.find(".timeStart");
    timeEnd = new_partial.find(".timeEnd");
    dayOfWeek.text($(elem).find('.days_of_week:not(.noValid) :selected').html() + " - ");
    impPerHour.text($(elem).find('.impressionsPerHour:not(.noValid)').val());
    timeStart.text($(elem).find('.timePickerStart:not(.noValid)').val());
    timeEnd.text($(elem).find('.timePickerEnd:not(.noValid)').val());
    if ($(elem).find('.days_of_week:not(.noValid) :selected').val() != undefined &&
      $(elem).find('.impressionsPerHour:not(.noValid)').val() != undefined && $(elem).find('.timePickerStart:not(.noValid)').val() != undefined &&
      $(elem).find('.days_of_week:not(.noValid) :selected').val() != undefined) {
      $("#current_row_hours").append(new_partial);
    }
  });
}

function buttonCount() {
  //when user clicks button add schedule in hourly campaign count goes up is for validate the user click the button
  count += 1;
}

function buttonSubstraction() {
  //when user clicks button trash in hourly campaign count goes down and is for validate the user have adding schedules
  setTimeout(function() {
    //Check that all fields are hidden for nested fields and add the class noValid
    for (var i = 0; i < $(document.querySelectorAll('.nested-fields')).length; i++) {
      if (document.querySelectorAll('.nested-fields')[i].style.display == "none") {
        $(document.querySelectorAll('.nested-fields')[i]).addClass('noValid');
        $(document.querySelectorAll('.noValid div select')[i]).addClass('noValid');
        for (var x = 0; x < $(document.querySelectorAll('.noValid div input')).length; x++) {
          $(document.querySelectorAll('.noValid div input')[x]).addClass('noValid');
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
    daysofweek = $(document.querySelectorAll('.days_of_week:not(.noValid)')[i]).parsley();
    impressionsperhour = $(document.querySelectorAll('.impressionsPerHour:not(.noValid)')[i]).parsley();
    timestart = $(document.querySelectorAll('.timePickerStart:not(.noValid)')[i]).parsley();
    timeend = $(document.querySelectorAll('.timePickerEnd:not(.noValid)')[i]).parsley();
    if (
      daysofweek.isValid() &&
      impressionsperhour.isValid() &&
      timestart.isValid() &&
      timeend.isValid() && count > 0
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
