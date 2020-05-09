$(document).on('turbolinks:load', function() {
  if ($("#api_token").length) {
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
          } catch {
            console.log("error")
            console.log(value);
          }
        });
      }).catch( (error) => console.log(error))
    }

    // show bilbo ad
    function showBilboAd() {
      $(".board-ads").hide();
      $("#bilbo-ad").show();
    }

    // show user ad
    function showAd() {
        if (bilbo_ad_count < 10 ) {
          ++bilbo_ad_count;
          ads = $(".board-ad-inner");
          chosen = Math.floor(Math.random() * ads.length);
          if ($("#bilbo-ad").is(":visible")) {
              $("#bilbo-ad").hide();
              $(".board-ads").show();
          }
          if (typeof newAd !== 'undefined') {
            oldAd = newAd;
            oldAd.css({display: "none"});
          }
          newAd = ads.eq(chosen).css({display: "block"});
          // build map for new ad displayed and merge it to displayedAds
          newAdMap = {campaign_id: $(newAd[0]).attr("data-campaign-id"), created_at: new Date(Date.now()).toISOString()}
          if (typeof newAdMap["campaign_id"] !== 'undefined') {
            displayedAds.push(newAdMap);
          }
          console.log(displayedAds);
        } else {
          showBilboAd();
          bilbo_ad_count = 0
        }

    }

    // initiate graphql
    var graph = graphql("/api")
    var rotateAds;
    var displayedAds = [];
    var api_token = $("#api_token").val();
    var board_slug = $(location).attr('pathname').split('/')[2]
    // counter for bilbo ad to be shown
    var bilbo_ad_count = 0
    // create the impressions every 60 seconds
    setInterval(createImpression, 60000);
    // Convert seconds to milliseconds
    board_duration = parseInt($("#duration").val()) * 1000;

    // Start stream
    $(".start-stream").click(function(){
      $(".start-stream").hide();
      $(".board-ads").show();
      rotateAds = setInterval(showAd, board_duration);
    });

  // Stop stream
    $("body").keyup(function (e) {
      // Stop option only if its started
      if ($(".start-stream").is(":hidden")) {
        // stop if Escape key is pressed
        if (e.keyCode === 27) {
          $(".start-stream").show();
          $(".board-ads").hide();
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
  }
})
