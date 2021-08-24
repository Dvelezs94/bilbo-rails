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
      onInit: function(event, currentIndex) {
        $("#dashboardWizard .content.clearfix").addClass("pd-0-f"); //removes padding so the map is full screen
      },
      onFinished: function(event, currentIndex) {
        $('.edit_campaign input[type=submit]').click();
      },
      onStepChanging: function (event, currentIndex, newIndex) {
        if(newIndex==0) {
          $("#dashboardWizard .content.clearfix").addClass("pd-0-f");
        }
        else {
          $("#dashboardWizard .content.clearfix").removeClass("pd-0-f");
        }
        if (currentIndex < newIndex) {
          // Step 1 form validation
          if (currentIndex === 0) {
            updateHiddenFieldContent();
            change_duration();
            var campaignboards = $('#campaign_boards').parsley();
            if (campaignboards.isValid()) {
              var x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
              if($("#board_count").length) $("#board_count")[0].innerHTML= x.length
              $("#board_count_summary")[0].innerHTML= x.length
              return true;
            } else {
              campaignboards.validate();
            }
          }

          if (currentIndex === 1) {
            updateHiddenFieldContent();
            if ($("#budget_distribution").length){
              fillBoardClasses();
              setBudgetAndImpressionsListeners();
              var x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
              $.each(x, function(index, board_id){
                calculateImpressions(board_id, $("#budget-"+board_id).val())
              });
            }
            if (validateContent()  && $("#content_ids").val() != ""){
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
            if ($('#budget_distribution').length) {
              var campaignstartsat = $('#campaign_starts_at').parsley();
              var campaignendsat = $('#campaign_ends_at').parsley();
              if ($('#date_campaign').prop('checked')) {
                [valid_budget, failed_at] = validateBudgetPerBilbo();
                if ( !valid_budget ) {
                  show_error($('#budget_error_message-'+failed_at).html());
                  return false;
                }

                if (
                  campaignstartsat.isValid() &&
                  campaignendsat.isValid()
                ) {
                  updateBudgetDistribution();
                  return true;
                } else {
                  campaignstartsat.validate();
                  campaignendsat.validate();
                  return false;
                }
              }
              [valid_budget, failed_at] = validateBudgetPerBilbo();
              if ( valid_budget ) {
                updateBudgetDistribution();
                return true;
              } else {
                show_error($('#budget_error_message-'+failed_at).html());
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
          });
          $('#bilbosNum').text($('#bilbosAddress li').length);
          if ($('#impressions').length == 1)
            $('#impressions')[0].style.width =
              ($('#campaign_budget')[0].value.length + 5) * 8 + 'px';
        } else if (priorIndex === 2) {
          $('#selected_boards option:not(:eq(0))').each(function () {
            // change size of preview in summary
            $('#carousel-'+$(this).data('slug')).width(
              $(this).attr('new-width')
            );
            $('#carousel-'+$(this).data('slug')).children()[0].style="height: " + $(this).attr('new-height') + 'px'
            $('#carousel-'+$(this).data('slug')).height(
              $(this).attr('new-height')
            );
          });
          x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
          $.each(x, function(index, board_id){
            if($("#budget-summary-"+board_id).length) $("#budget-summary-"+board_id)[0].innerHTML = currencyFormat($("#budget-"+board_id).val() || "0")+ " MXN"
            if($("#impressions-summary-"+board_id).length) $("#impressions-summary-"+board_id)[0].innerHTML = $("#impressions-"+board_id).val()
          });
          getSummaryInfo();
          if($("#frequency").length) computePerMinuteTotalBudget();
          if($("#total_budget").length) $('#total_budget_summary').text($("#total_budget")[0].innerHTML);
          //show alert if user has not enough credits to run the campaign
          setTimeout(function(){
            var campaign_budget = parseFloat($("#total_budget_summary")[0].innerHTML.replace(/[^\d.-]/g, ''))
            var user_balance = parseFloat($("#user_balance").val())
            if(user_balance < campaign_budget && $("#project_classification").val() == "user"){
              $("#out_of_credits")[0].classList.remove('invisible')
            }
          },500);
        }
      },
    });
    // End Jquery steps

    if($("#budget_distribution").length){
      new PerfectScrollbar('#tablebody', {
          suppressScroll: true
      });
    }
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

    function validateBudgetPerBilbo(){
      x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
      var valid = true
      var failed_at = null
      $.each(x, function(index, board_id){
        assigned_budget = parseFloat($("#budget-"+board_id).val())
        minimum_budget = parseFloat($("#minimum-"+board_id).val())
        if(assigned_budget < minimum_budget){
          valid = false
          failed_at = board_id
          return
        }
      });
      return [valid, failed_at]
    }

    function setBudgetAndImpressionsListeners(){
      x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
      $.each(x, function(index, board_id) {
        $("#budget-"+board_id).on("keyup change paste", function(){
          calculateImpressions(board_id,$("#budget-"+board_id).val())
        });
        $("#impressions-"+board_id).on("keyup change paste", function(){
          calculateBudget(board_id,$("#impressions-"+board_id).val())
        });
      });
    }

    function updateBudgetDistribution(){
      x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
      distribution = {}
      $.each(x, function(index, board_id){
        distribution[board_id] = $("#budget-"+board_id).val()
      })
      $("#budget_values").val(JSON.stringify(distribution))
    }

    function calculateImpressions(board_id, budget){
      // console.log(board);
      board = $("#selected_boards [value="+board_id+"]")[0]
      cycles = parseInt($("#campaign_bilbo_duration").val() || parseInt($(board).data('cycle-duration')));
      budget = parseFloat(budget)
      imp = parseInt(budget / ($(board).data('price')*cycles)) || 0
      max_imp = $(board).data('max-impressions')
      if (imp > max_imp) {
        imp = parseInt($(board).data('max-impressions'))
        calculateBudget(board_id, imp)
        $("#impressions-"+board_id).val(imp)
      } else {
      $("#impressions-"+board_id).val(imp)
      updateTotalBudget();
      }
    }

    function fillBoardClasses(){
      x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
      classes = []
      $.each(x, function(index, board_id){
        classes.push($("#board-class-"+board_id).val())
      });
      uniqueClasses = [];
      $.each(classes, function(i, el){
        if($.inArray(el, uniqueClasses) === -1) uniqueClasses.push(el);
      });
      result = uniqueClasses.join(', ')
      // console.log(result)
      $("#board_class")[0].innerHTML = result
    }

    function calculateBudget(board_id, desired_impressions){
      max_imp = parseInt($(board).data('max-impressions'))
      desired_impressions = parseInt(desired_impressions)
      if(desired_impressions > max_imp){
        desired_impressions = max_imp
        $("#impressions-"+board_id).val(desired_impressions)
      }
      board = $("#selected_boards [value="+board_id+"]")[0]
      cycles = parseInt($("#campaign_bilbo_duration").val() || parseInt($(board).data('cycle-duration')));
      budget = (desired_impressions * $(board).data('price')*cycles) || 0
      budget = Math.ceil(budget*2)/2;
      $("#budget-"+board_id).val(budget)
      updateTotalBudget();
    }

    function updateTotalBudget(){
      var x = $("#campaign_boards").val().split(',').filter((el) => {return el != ""});
      total_budget = 0
      $.each(x, function(index, board_id){
        total_budget += parseFloat($("#budget-"+board_id).val() || 0)
      })
      $("#total_budget")[0].innerHTML=currencyFormat(total_budget*parseInt($("#active_days").val()) || "0")
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
            $("#campaign_bilbo_duration").val()
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
        cycles = parseInt($("#campaign_bilbo_duration").val() || parseInt($(this).data('cycle-duration')));
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
        cycles = parseInt($("#campaign_bilbo_duration").val() || parseInt($(this).data('cycle-duration')));
        board_price = impressions * $(this).data('price') * cycles;
        total_price += board_price;
      });
      return Math.ceil(total_price*2)/2; //Round the budget to the nearest multiple of 0.5 that is higher than the value found
    }

  }
});
function currencyFormat(num) {
  // console.log(num)
  return '$' + (parseFloat(num) || 0.00).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
}

function computePerMinuteTotalBudget(){
  var total_budget = 0
  $('#selected_boards option:not(:eq(0))').each(function() {
    var working_minutes = parseFloat($(this).data('max-impressions'))/6
    cycles = parseInt($("#campaign_bilbo_duration").val() || parseInt($(this).data('cycle-duration')));
    price = $(this).data('price') * cycles;
    total_budget += price * parseFloat($("#imp_minute").val()) / $("#campaign_minutes").val() * working_minutes
  });
  $("#frequency")[0].innerHTML = $("#imp_minute").val() + " " + $("#translation_impressions_each").val() + " " + $("#campaign_minutes").val() + " " + $("#translation_minutes").val()

  $("#total_budget_summary")[0].innerHTML = currencyFormat(total_budget*parseInt($("#summary_active_days").val())) + " MXN"
}

function showOrHideSizeAlert(){
  $(".carousel").each(function(){
    // Show or hide message for the first image on each carousel
    first_image = this.getElementsByClassName('active')
    slug = String(this.id).slice(9)
    board = $("#selected_boards [data-slug=" + slug + "]")[0]
    board_width = $(board).attr('new-width')
    board_height = $(board).attr('new-height')
    if(first_image.offsetWidth / first_image.offsetHeight != board_width / board_height){
      $("#wrong_size_alert_"+slug)[0].classList.remove('invisible')
    } else {
      $("#wrong_size_alert_"+slug)[0].classList.add('invisible')
    }
    // show or hide message for the rest of the images on the carousel
    $(this).on('slid.bs.carousel', function(e){
      slug = String(this.id).slice(9)
      board = $("#selected_boards [data-slug=" + slug + "]")[0]
      board_width = $(board).attr('new-width')
      board_height = $(board).attr('new-height')
      new_img = e.relatedTarget.children[0]
      if(new_img.offsetWidth / new_img.offsetHeight != board_width / board_height){
        $("#wrong_size_alert_"+slug)[0].classList.remove('invisible')
      } else {
        $("#wrong_size_alert_"+slug)[0].classList.add('invisible')
      }
    });
  });
}


function count_rows_per_day_of_week(){
  //count how many rows we need to use for the summary table for campaigns per hour
  rows_count = {}
  daysOfWeek = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
  var hour_rows = $('[hour_row]');
  $.each(hour_rows, function (index, elem) {
    week_day = elem.querySelectorAll('select')[0].value
    if(week_day == 'everyday'){
      $.each(daysOfWeek, function(index, day){
        if(rows_count[day]){ rows_count[day] += 1 }
        else{ rows_count[day] = 1 }
      });
    } else {
      if(rows_count[week_day]){ rows_count[week_day] += 1 }
      else{ rows_count[week_day] = 1 }
    }
  });
  return rows_count
}


function make_summary_selected_hours() {
  var hour_rows = $('[hour_row]');
  daysOfWeek= ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
  day_row = {}
  $.each(daysOfWeek, function(index,elem){
    day_row[elem] = 0;
  });
  $.each(hour_rows, function (index, elem) {
    week_day = elem.querySelectorAll('select')[0].value
    row_budget = parseFloat(elem.querySelectorAll('input.budget')[0].value)
    row_impressions = parseInt(elem.querySelectorAll('input.impressionsPerHour')[0].value)
    row_start_time = elem.querySelectorAll('.timePickerStart')[0].value
    row_end_time = elem.querySelectorAll('.timePickerEnd')[0].value
    if(week_day == "everyday"){
      $.each(daysOfWeek, function(index, day){
        $("#budget_"+day)[0].innerHTML = (parseFloat($("#budget_"+day)[0].innerHTML) || 0) + row_budget
        $("#impressions_"+day+"_"+day_row[day])[0].innerHTML = row_impressions
        $("#ranges_"+day+"_"+day_row[day])[0].innerHTML += (row_start_time.slice(0,5) + ' - ' + row_end_time.slice(0,5))
        day_row[day] += 1
      });
    } else {
      $("#budget_"+week_day)[0].innerHTML = (parseFloat($("#budget_"+week_day)[0].innerHTML) || 0) + row_budget
      $("#impressions_"+week_day+"_"+day_row[week_day])[0].innerHTML = row_impressions
      $("#ranges_"+week_day+"_"+day_row[week_day])[0].innerHTML += (row_start_time.slice(0,5) + ' - ' + row_end_time.slice(0,5))
      day_row[week_day] += 1
    }
  });

  //Compute the total budget according to each week_day investment and the start and end date of the campaign
  var start = new Date($("#start_date").val())
  var end = new Date($("#end_date").val())
  total_budget = 0
  number_of_days = (end-start)/86400000
  for(var i = 0; i<= number_of_days; i++){
    week_day_number = new Date(start.getTime() + 86400000*i).getDay()
    week_day = week_day_number == 0? "sunday" : daysOfWeek[week_day_number - 1]
    total_budget += parseFloat($("#budget_"+week_day)[0].innerHTML)
  }

  $("#total_budget_summary")[0].innerHTML = currencyFormat(total_budget) + " MXN"

  $.each(daysOfWeek, function(index, day){
    $("#budget_"+day)[0].innerHTML = currencyFormat($("#budget_"+day)[0].innerHTML) + " MXN"
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

function getSummaryInfo(){
  $.ajax({
    url:  "/contents_board_campaign/get_summary_info",
    dataType: "script",
    data: {selected_contents: $("#content_ids").val(), table_rows: JSON.stringify(count_rows_per_day_of_week()), campaign_id: $("#campaign_id").val()},
    success: function(data) {
    },
    error: function(data) {
      alert("Oops.. Ocurrio un error..");
    }
  });
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
  var arr = $('#'+"slug-"+board_slug).val().split(" ");
    for( var i = 0; i < arr.length; i++){
        if ( arr[i] === content_id) {
            arr.splice(i, 1);
            i--;
        }
    }
    $('#slug-'+board_slug).val(arr.toString().replace(/,/g , " "));
    updateHiddenFieldContent();
}

function updateHiddenFieldContent(){
  contents_selected = $('input*[id*=slug-bilbo-]');
  var content_board_campaign = {}
  var i;
  for (i = 0; i < contents_selected.length; i++) {
    var str = contents_selected[i].id;
    var slug = str.split("slug-").pop();
    x = $("#"+contents_selected[i].id);
    content_board_campaign[slug] = x.val();
  }
  $("#content_ids").val(JSON.stringify(content_board_campaign))
  if($("#content_ids").val() === "{}" ){
    $("#content_ids").val("");
  }
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
  board_content_selected = $('input*[id*=slug-bilbo-]');
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
    bilbo_duration_change.text(bilbo_duration_change.text().replace(bilbo_duration_change.text().split(" ")[0], campaign_bilbo_duration.val()));
  });
}
