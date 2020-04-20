$(document).on('turbolinks:load', function() {
  if ($("#api_token").length) {
    function createImpression() {
      // build the query
      var impressionMutation = graph.mutate(`
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
        }).then((data)=> {
          console.log(data);
        }).catch(function(e) {
            console.log(e); // print error
        });
      });
      
      graph.commit('buildImpression').then(function (response) {
        // All base fields will be in response return.
        // console.log(response);
        response["createImpression"].forEach((value, index)=>{
          //console.log(value["impression"]["createdAt"]);
          displayedAds = displayedAds.filter((impression) => {
            return impression.createdAt === value["impression"]["createdAt"];
          });
        });
      }).catch( (error) => console.log(error))
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
    var api_token = $("#api_token").val();
    var board_slug = $(location).attr('pathname').split('/')[2]
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
 }
})
