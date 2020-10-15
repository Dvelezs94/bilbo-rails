 $(document).on('turbolinks:load', function() {
   if ($("#api_token").length) {
     // initiate graphql
     var graph = graphql("/api")
     var rotateAds;
     displayedAds = [];
     var api_token = $("#api_token").val();
     var board_slug = $(location).attr('pathname').split('/')[2]
     // starts depending on the hour
     var rotation_key = 0
     // create the impressions every 60 seconds
     setInterval(createImpression, 60000);
     // Convert seconds to milliseconds
     board_duration = parseInt($("#duration").val()) * 1000;

     // Start stream
     $(".start-stream").click(function() {
       rotation_key = getIndex($("#start_time").val());
       $(".start-stream").hide();
       $(".board-ads").attr('style', 'display:block !important');
       // give 5 seconds to load all images and videos
       setTimeout(function(){
         showAd();
         rotateAds = setInterval(showAd, board_duration);
       }, 5000);

     });

     // Stop stream
     $("body").keyup(function(e) {
       // Stop option only if its started
       if ($(".start-stream").is(":hidden")) {
         // stop if Escape key is pressed
         if (e.keyCode === 27) {
           $(".start-stream").attr('style', 'display:block !important');
           $(".board-ads").hide();
           $("#bilbo-ad").hide();
           clearInterval(rotateAds);
           $(".board-ad-inner").css({
             display: "none"
           });
         }
       }
     });

     // auto start
     // &autoplay=true should be added to the params on the url
     if ($.urlParam('autoplay') == "true") {
       console.log("starting autoplay");
       $(".start-stream").trigger("click");
     }

     ///////////////////// FUNCTIONS  /////////////////////

     function createImpression() {
       // build the query
       var impressionMutation = graph.mutate(`
        createImpression(input: {
          apiToken: $api_token,
          boardSlug: $board_slug,
          campaignId: $campaign_id,
          mutationid: $mutation_id,
          cycles: 1,
          createdAt: $created_at
        }) {
          impression {
            id
            totalPrice
            createdAt
          }
          mutationid
          errors
          action
        }
      `);

       displayedAds.forEach((value, index) => {
         impressionMutation.merge('buildImpression', {
           api_token: api_token,
           board_slug: board_slug,
           campaign_id: value["campaign_id"],
           created_at: value["created_at"],
           mutation_id: value["mutationid"]
         }).then((response) => {
           return response;
         }).catch(function(e) {
           console.log(e); // print error
         });
       });
       try {
         graph.commit('buildImpression').then(function(response) {
           // All base fields will be in response return.
           // console.log("Response");
           // console.log(response);
           // console.log("DisplayedAdsAntes");
           // console.log(displayedAds);
           // console.log(displayedAds.length);
           response["createImpression"].forEach((value, index) => {
             // console.log("ACTION");
             // console.log(value["action"]);
             if ( value["action"] != "delete") return;
             displayedAds = displayedAds.filter((impression) => {
               return impression.mutationid != value["mutationid"]
             });
           });
           // console.log("DisplayedAdsDespues");
           // console.log(displayedAds);
           // console.log(displayedAds.length);
         }).catch((error) => console.log(error))
       } catch (value) {
         if (value.message == "You cannot commit the merge buildImpression without creating it first.") {
           console.log("There aren't impressions to add");
         } else {
           throw value;
         }
       }
     }

     // show user ad
     function showAd() {
       ads = jQuery.parseJSON($("#ads_rotation").val());
       // restart from beginning if the array was completely ran
       if (rotation_key >= ads.length) rotation_key = 0;

       chosen = ads[rotation_key];

       if (chosen == "-"){
         showBilboAd();
         check_next_campaign_ads_present();
       }
       else if (chosen != "."){
         hideBilboAd();
         //hide the old ad and pause it if its video
         if (typeof newAd !== 'undefined') {
           oldAd = newAd;
           oldAd.css({
             display: "none"
           });
           if ($(adPausePlay).is("video")) {
             adPausePlay.pause();
             adPausePlay.currentTime = 0;
           }
         }
         //display new ad
         newAdLength = $('[data-campaign-id="' + chosen + '"]').length;
         if (newAdLength > 0) { // means there is an ad for that campaign on view
           newAdChosen = Math.floor(Math.random() * newAdLength);
           newAd = $($('[data-campaign-id="' + chosen + '"]')[newAdChosen]).css({
             display: "block"
           });
           adPausePlay = $('[data-campaign-id="' + chosen + '"]')[newAdChosen]
           if ($(adPausePlay).is("video")) {
             adPausePlay.play();
           }
           // build map for new ad displayed and merge it to displayedAds
           newAdMap = {
             campaign_id: chosen.toString(),
             created_at: new Date(Date.now()).toISOString(),
             mutationid: Array(15).fill(null).map(() => Math.random().toString(36).substr(2)).join('')
           }
           if (typeof newAdMap["campaign_id"] !== 'undefined') {
             displayedAds.push(newAdMap);
           }
           check_next_campaign_ads_present();
         } else { //no ad so i need to display bilbo ad and ask for the ad
           console.log("no ads for campaign " +  String(chosen) + ", requesting them and showing bilbo ad for this time");
           showBilboAd();
           requestAds(chosen);
         }
         //console.log(displayedAds);
         // else it is empty, so we need to show the bilbo hire
       }
       // increase rotation key
       ++rotation_key;
     }
     // show bilbo ad
     function showBilboAd() {
       pauseAllCampaignVideos();
       var chosen_default_multimedia = Math.floor(Math.random() * $(".bilbo-official-ad").length);
       $(".board-ads").hide();
       $("#bilbo-ad").attr('style', 'display:block !important');
       $(".bilbo-official-ad").hide().eq(chosen_default_multimedia).show()
       if ($($(".bilbo-official-ad")[chosen_default_multimedia]).is("video")) {
         $(".bilbo-official-ad")[chosen_default_multimedia].currentTime = 0;
         $(".bilbo-official-ad")[chosen_default_multimedia].play();
       }
     }

     function pauseDefaultVideos() {
       $(".bilbo-official-ad").each(function() {
         if ($(this).is("video")) {
           if (!this.paused) {
             this.pause();
             this.currentTime = 0;
           }
         }
       });
     }

     function pauseAllCampaignVideos() {
       $(".board-ad-inner").each(function() {
         if ($(this).is("video")) {
           if (!this.paused) {
             this.pause();
             this.currentTime = 0;
           }
         }
       });
     }

     function check_next_campaign_ads_present() {
        //check if next campaign has ads to download them
       next_chosen = (rotation_key >= ads.length)?  ads[0] : ads[rotation_key+1];
       if (next_chosen != "-" && next_chosen != "."){
         nextAdLength = $('[data-campaign-id="' + next_chosen + '"]').length;
         if (nextAdLength == 0) {
           console.log("next campaign with id "+next_chosen+" has no ads, requesting them");
           requestAds(next_chosen);
         }
       }
     }
     function requestAds(campaign_id) {
       board_id = $("#board_id").val()
       Rails.ajax({
        url: "/campaigns/" + String(campaign_id) + "/getAds",
        type: "get",
        data: "board_id="+String(board_id),
        success: function(data) {
          console.log("retrieved ads for campaign " + String(campaign_id));
        },
        error: function(data) {
          console.log("error retrieving ads for campaign "+ String(campaign_id));
        }
      })
     }
     function hideBilboAd(){
       if ($("#bilbo-ad").is(":visible")) {
         pauseDefaultVideos();
         $("#bilbo-ad").hide();
         $(".board-ads").attr('style', 'display:block !important');
       }
     }

     function getIndex(start_time) {
       start_date = new Date(start_time);
       start_hours = start_date.getHours();
       start_minutes = start_date.getMinutes();
       start_seconds = start_date.getSeconds();

       start_seconds = start_hours * 3600 + start_minutes * 60 + start_seconds;

       current_hours = new Date().getHours();
       current_minutes = new Date().getMinutes();
       current_seconds = new Date().getSeconds();

       current_seconds = current_hours * 3600 + current_minutes * 60 + current_seconds;
       if (current_seconds < start_seconds) { //fixes when bilbo changes day
         current_seconds += 86400; //plus one day (seconds)
       }
       index_seconds = current_seconds - start_seconds
       b_duration = parseInt(board_duration/1000)
       current_seconds = index_seconds - index_seconds % b_duration; // go to the previous index

       current_index = parseInt(current_seconds / b_duration);
       return current_index;
     }
   }
 });

 function updateQueryStringParameter(uri, key, value) {
   var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
   var separator = uri.indexOf('?') !== -1 ? "&" : "?";
   if (uri.match(re)) {
     return uri.replace(re, '$1' + key + "=" + value + '$2');
   } else {
     return uri + separator + key + "=" + value;
   }
 }
