$(document).on('turbolinks:load', function() {
  if ($("#api_token").length) {
    // initiate graphql
    var graph = graphql("/api")
    var rotateAds;
    displayedAds = [];
    var api_token = $("#api_token").val();
    var board_slug = $(location).attr('pathname').split('/')[2]
    // counter for bilbo ad to be shown
    var bilbo_ad_count = 0
    // starts depending on the hour
    var rotation_key = 0
    // create the impressions every 60 seconds
    setInterval(createImpression, 60000);
    // Convert seconds to milliseconds
    board_duration = parseInt($("#duration").val()) * 1000;

    // Start stream
    $(".start-stream").click(function(){
      rotation_key = getIndex($("#start_time").val());
      $(".start-stream").hide();
      $(".board-ads").attr('style','display:block !important');
      rotateAds = setInterval(showAd, board_duration);
    });

  // Stop stream
    $("body").keyup(function (e) {
      // Stop option only if its started
      if ($(".start-stream").is(":hidden")) {
        // stop if Escape key is pressed
        if (e.keyCode === 27) {
          $(".start-stream").attr('style','display:block !important');
          $(".board-ads").hide();
          $("#bilbo-ad").hide();
          clearInterval(rotateAds);
          $(".board-ad-inner").css({display: "none"});
        }
      }
    });

    // auto start
    // &autoplay=true should be added to the params on the url
    if ($.urlParam('autoplay') == "true") {
      console.log("starting autoplay");
      $( ".start-stream" ).trigger( "click" );
    }

    ///////////////////// FUNCTIONS  /////////////////////

    function createImpression() {
      // build the query
      var impressionMutation = graph.mutate(`
        createImpression(input: {
          apiToken: $api_token,
          boardSlug: $board_slug,
          campaignId: $campaign_id,
          cycles: 1,
          createdAt: $created_at
        }) {
          impression {
            id
            totalPrice
            createdAt
          }
          errors
        }
      `);

      displayedAds.forEach((value, index)=>{
        impressionMutation.merge('buildImpression', {
            api_token: api_token,
            board_slug: board_slug,
            campaign_id: value["campaign_id"],
            created_at: value["created_at"]
        }).then((response)=> {
            return response;
        }).catch(function(e) {
            console.log(e); // print error
        });
      });

      graph.commit('buildImpression').then(function (response) {
        // All base fields will be in response return.
        //console.log(response);
        response["createImpression"].forEach((value, index)=>{
          //console.log(value["impression"]["createdAt"]);
          try {
            displayedAds = displayedAds.filter((impression) => {
              return impression.createdAt === value["impression"]["createdAt"];
            });
          } catch (value) {
            console.log("error")
            console.log(value);
          }
        });
      }).catch( (error) => console.log(error))
    }

    // show user ad
    function showAd() {
      if (bilbo_ad_count < 10 ) {
        // don't increase count so bilbo ad is not shown every 10 ads
        //++bilbo_ad_count;
        ads = jQuery.parseJSON($("#ads_rotation").val());
        // restart from beginning if the array was completely ran
        if (rotation_key >= ads.length) {
          rotation_key = 0
        }
        chosen = ads[rotation_key];
        if (chosen !== "-") {
          if ($("#bilbo-ad").is(":visible")) {
              $("#bilbo-ad").hide();
              $(".board-ads").attr('style','display:block !important');
          }
          if (typeof newAd !== 'undefined') {
            oldAd = newAd;
            oldAd.css({display: "none"});
          }
          newAdLength = $('[data-campaign-id="' + chosen + '"]').length;
          newAdChosen = Math.floor(Math.random() * newAdLength);
          newAd = $($('[data-campaign-id="' + chosen + '"]')[newAdChosen]).css({display: "block"});
          // build map for new ad displayed and merge it to displayedAds
          newAdMap = { campaign_id: chosen.toString(), created_at: new Date(Date.now()).toISOString() }
          if (typeof newAdMap["campaign_id"] !== 'undefined') {
            displayedAds.push(newAdMap);
          }
          console.log(displayedAds);
          // else it is empty, so we need to show the bilbo hire
        } else {
          showBilboAd();
        }
      } else {
        showBilboAd();
        bilbo_ad_count = 0
      }
      // increase rotation key
      ++rotation_key;
    }
    // show bilbo ad
    function showBilboAd() {
      $(".board-ads").hide();
      $("#bilbo-ad").attr('style','display:block !important');
    }
    function getIndex(start_time) {
      start_date = new Date(start_time);
      start_hours = start_date.getHours();
      start_minutes = start_date.getMinutes();
      start_seconds = start_date.getSeconds();

      start_seconds = start_hours*3600 + start_minutes*60 + start_seconds;

      current_hours = new Date().getHours();
      current_minutes = new Date().getMinutes();
      current_seconds = new Date().getSeconds();

      current_seconds = current_hours*3600 + current_minutes*60 + current_seconds;
      if (current_seconds < start_seconds) { //fixes when bilbo changes day
        current_seconds += 86400; //plus one day (seconds)
      }
      index_seconds = current_seconds - start_seconds

      current_seconds = index_seconds - index_seconds%10 // go to the previous index

      current_index = parseInt(current_seconds/10);
      return current_index;
    }
  }
});

function updateQueryStringParameter(uri, key, value) {
  var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  var separator = uri.indexOf('?') !== -1 ? "&" : "?";
  if (uri.match(re)) {
    return uri.replace(re, '$1' + key + "=" + value + '$2');
  }
  else {
    return uri + separator + key + "=" + value;
  }
}
