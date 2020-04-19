$(document).on('turbolinks:load', function() {
  function createImpression() {
    console.log("hey");
    // build the query
    var impressionMutation = graph.mutate(`{
      createImpression(input: {
        apiToken: $api_token,
        boardSlug: $board_slug,
        campaignId: $campaign_id ,
        cycles: 1,
        createdAt: $created_at
      }) {
        impression {
          id
          totalPrice
        }
        errors
      }
    }`);

    displayedAds.forEach((index, value)=>{
      impressionMutation.merge('buildImpression', {
          api_token: api_token,
          board_slug: board_slug,
          campaign_id: value["campaign_id"],
          created_at: value["created_at"]
      }).then((response)=> {
          return response.json();
      }).then((data)=> {
        console.log(data);
      }).catch(function(e) {
          console.log(e); // print error
      });
    })

  }

  function showAd() {
      ads = $(".board-ad-inner");
      chosen = Math.floor(Math.random() * ads.length);

      if (typeof newAd !== 'undefined') {
        oldAd = newAd;
        oldAd.css({display: "none"});
      }
      newAd = ads.eq(chosen).css({display: "block"});
      // build map for new ad displayed and merge it to displayedAds
      newAdMap = {campaign_id: $(newAd[0]).attr("data-campaign-id"), created_at: new Date(Date.now()).toISOString()}
      displayedAds.push(newAdMap);
      //console.log(displayedAds);
  }

  // initiate graphql
  var graph = graphql("/api")
  var rotateAds;
  var displayedAds = [];
  var api_token = $("#duration").val();
  var board_slug = $(location).attr('pathname').split('/')[2]
  // create the impressions every 60 seconds
  setInterval(createImpression, 10000);
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

})
