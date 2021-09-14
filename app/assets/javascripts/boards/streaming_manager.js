$(document).on('turbolinks:load', function() {
   if ($("#api_token").length && document.URL.includes( $("[data-board]").attr("data-board") + "?access_token=" + $("#access_token").val())) {
     // initiate graphql
     var graph = graphql("/api")
     var rotateAds;
     displayedAds = [];
     var api_token = $("#api_token").val();
     var board_slug = $(location).attr('pathname').split('/')[2];
     var work_hour_start = $("#work_hours").val().split("-")[0];
     var work_hour_end = $("#work_hours").val().split("-")[1];
     // starts depending on the hour
     var rotation_key = 0;
     var last_request_time = {} //prevent for multiple request for a single content download
     var lost_impressions = 0;
     // create the impressions every 60 seconds
     initializePlayer().then((readyToStart) => {
       if(readyToStart){
         setInterval(createImpression, 60000);
         setInterval(reloadAdsRotation, 3600000); //update the ads rotation every hour only if there was lost impressions on the board due to media loading
         // Convert seconds to milliseconds
         board_duration = parseInt($("#duration").val()) * 1000;

         //request a new ads_rotation at the beginning of each day
         setTimeout(function(){
           requestAdsRotation();
           setInterval(requestAdsRotation,86400000) // 1 day interval (ms)
         },(timeUntilNextStart()-5)*1000) //Time for next start hour of the board

         // reload Bilbo after running 24 hours straight
         setTimeout(function(){ window.location.reload() }, 86400000);
         //reload all iframes every hour
         setInterval(function(){
           var d = new Date();
           //console.log("reloading iframes at: " + d.toDateString())
           $('iframe').each(function() {
             this.src = this.src;
           });
         }, 3600000) //run every hour of the day

         // Start stream
           rotation_key = getIndex($("#start_time").val());
           $(".board-ads").attr('style', 'display:block !important');
           // give 5 seconds to load all images and videos
           setTimeout(function() {
             showAd();
             rotateAds = setInterval(showAd, board_duration);
           }, 5000);
       } else {
         if(server_time != ""){
           alert("La hora del sistema no coincide con la hora del servidor\nAjuste la hora e intente nuevamente\nHora del servidor: "+server_time);
         } else {
           alert("No se pudo obtener la hora del servidor, revisa tu conexión y vuelve a intentarlo")
         }
       }
    });
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
          mutationid
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
          //  console.log("Response");
          //  console.log(response);
           // console.log("DisplayedAdsAntes");
           // console.log(displayedAds);
           // console.log(displayedAds.length);
           response["createImpression"].forEach((value, index) => {
             // console.log("ACTION");
             // console.log(value["action"]);
             // if action is not delete, then keep it because it means there was an error
            //  console.log(value);
             if (value["action"] != "delete") {
              return;
             } else {
              displayedAds = displayedAds.filter((impression) => {
                return impression.mutationid != value["mutationid"]
              });
             }
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
       optimize_memory(rotation_key,board_slug);
       chosen = ads[rotation_key];
       if (isWorkTime(work_hour_start, work_hour_end)){
         if (chosen == "-") {
         showBilboAd();
         check_next_campaign_ads_present();
         } else if (chosen != ".") {
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
             validAds = filterValidMedia($('[data-campaign-id="' + chosen + '"]'));
             newAdLength = validAds.length;
             if (newAdLength > 0) { // means there is an ad for that campaign on view
               newAdChosen = Math.floor(Math.random() * newAdLength);
               newAd = $(validAds[newAdChosen]).css({
                 display: "block"
               });
               adPausePlay = validAds[newAdChosen]
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
             } else { //no ad so i need to display bilbo ad and ask for the ad
               console.log("no ads for campaign " + String(chosen) + ", requesting them and showing bilbo ad for this time");
               Bugsnag.notify("El contenido de la campaña " + chosen + " no se ha podido mostrar en el bilbo " + board_slug + ", se recargarán los recursos y se mostrará el contenido default esta vez" )
               showBilboAd();
               //If the HTML has the media object then it's not necessary to request the ads with ajax, we just reload their src to download the resources
               if($('[data-campaign-id="'+chosen+'"]').length == 0){
                 requestAds(chosen);
               } else {
                 reloadContent(chosen)
               }
               lost_impressions += 1;
             }
             check_next_campaign_ads_present();
             //console.log(displayedAds);
             // else it is empty, so we need to show the bilbo hire
           }
       } else {
         --rotation_key;
         showBilboAd();
       }
       // increase rotation key
       ++rotation_key;
     }


function isWorkTime(start, end) {
  //function that checks if the dashboard is out of the hour range and only shows provider ads by default
  today = new Date();
  current_hour = addZero(today.getHours()) + ":" + addZero(today.getMinutes());
  if (start < end) {
    if (current_hour >= start && current_hour < end) {
      return true;
    } else {
      return false;
    }
  } else if (start == end) {
    return true;
  } else {
    if (!(current_hour > end && current_hour <= start)) {
      return true;
    } else {
      return false;
    }
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
     b_duration = parseInt(board_duration / 1000)

     current_index = parseInt(index_seconds / b_duration);
     return current_index;
   }
   // show bilbo ad
   function showBilboAd() {
     //pauseAllCampaignVideos();
     availableAds = filterValidMedia($(".bilbo-official-ad"))
     var chosen_default_multimedia = Math.floor(Math.random() * availableAds.length);
     $(".board-ads").hide();
     $("#bilbo-ad").attr('style', 'display:block !important');
     $(".bilbo-official-ad").hide()
     availableAds.eq(chosen_default_multimedia).show()
     if ($(availableAds[chosen_default_multimedia]).is("video")) {
       availableAds[chosen_default_multimedia].currentTime = 0;
       availableAds[chosen_default_multimedia].play();
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

  function filterValidMedia(collection){
    collection = collection.filter((index,element) => {
      return mediaReady(element)
    });
    return collection;
  }

  function mediaReady(elem){
    //for each content type, we have a way to verify if the content can be shown
    if($(elem).is("video")){
      return elem.readyState >= 1 && [1,2].includes(elem.networkState);
    } else if($(elem).is("img")){
      return elem.complete && elem.naturalHeight != 0;
    } else {
      //check conditions for iframes
      return true
    }
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
     next_chosen = (rotation_key >= ads.length) ? ads[0] : ads[rotation_key + 1];
     if (next_chosen != "-" && next_chosen != ".") {
       nextAds = $('[data-campaign-id="' + next_chosen + '"]');
       nextAds = filterValidMedia(nextAds);
       if (nextAds.length == 0) {
         console.log("next campaign with id " + next_chosen + " has no ads or haven't been completely loaded, requesting them");
         if($('[data-campaign-id="'+next_chosen+'"]').length == 0){
           requestAds(next_chosen);
         } else {
           reloadContent(next_chosen);
         }
       }
     } else if (next_chosen == "-") {
       //verify that at least one default content is available
       defaultContent = filterValidMedia($(".bilbo-official-ad"));
       if(defaultContent.length == 0){
         console.log("No default content available, trying to download it");
         reloadContent('-');
       }
     }
   }

   function requestAds(campaign_id) {
     board_id = $("#board_id").val();
     Rails.ajax({
       url: "/campaigns/" + String(campaign_id) + "/get_content",
       type: "get",
       data: "board_id=" + String(board_id),
       success: function(data) {
         console.log("retrieved ads for campaign " + String(campaign_id));
       },
       error: function(data) {
         console.log("error retrieving ads for campaign " + String(campaign_id));
       }
     })
   }

   function reloadContent(campaign_id) {
     if(campaign_id == '-' && new Date() - last_request_time['-'] > 600000){
       last_request_time['-'] = new Date();
       $(".bilbo-official-ad").forEach((item, i) => {
         //re-assign the url of the content for video and image to force a reload/download of the media
         if(!mediaReady(item) && ($(item).is("video") || $(item).is("img"))) {
           item.src = item.src;
         }
       });
     } else if(new Date() - last_request_time[campaign_id] > 600000){
       last_request_time[campaign_id] = new Date();
       //Get media that is not available to reload it
       $('[data-campaign-id="' + campaign_id + '"]').forEach((item, i) => {
         //reload only the contents that aren't completely loaded
         if(!mediaReady(item) && ($(item).is("video") || $(item).is("img"))) {
           item.src = item.src;
         }
       });
     }
   }

   function hideBilboAd() {
     if ($("#bilbo-ad").is(":visible")) {
       //pauseDefaultVideos();
       $("#bilbo-ad").hide();
       $(".board-ads").attr('style', 'display:block !important');
     }
   }

  function secondsUntilNextDay(){
    current_time = new Date();
    hours = current_time.getHours();
    minutes = current_time.getMinutes();
    seconds = current_time.getSeconds();

    total_seconds = hours*3600 + minutes*60 + seconds;
    return 86400 - total_seconds;
  }

  function reloadAdsRotation() {
    if(lost_impressions > 0){
      requestAdsRotation();
      lost_impressions = 0;
    }
  }

  function requestAdsRotation() {
    board_id = $("#board_id").val();
    api_token = $("#api_token").val();
    Rails.ajax({
      url: "/boards/" + String(board_id) + "/requestAdsRotation.js",
      type: "post",
      data: "api_token=" + String(api_token),
      success: function(data) {
        //nothing
      },
      error: function(data) {
        console.log("error retrieving new ads rotation");
      }
    })
  }

  async function initializePlayer(){
    server_time = ""
    url = window.location
    time_api_path = url.protocol + "//" + url.host + "/api/v1/boards/board_time?slug="+board_slug
    for(var i = 0; i < 5; i++){
      response = await fetch(time_api_path)
      if(response.status !== 200){ continue;}
      response.json().then(function(data){
        server_time = data["board_time"];
        return;
      })
      if(server_time != "") break;
    }

    if(server_time == ""){
      Bugsnag.notify("No se pudo obtener la hora del servidor en el bilbo " + board_slug)
      return false
    }

    server_hours = parseInt(server_time.split(':')[0]);
    server_minutes = parseInt(server_time.split(':')[1]);
    server_minutes = server_minutes + server_hours*60;

    player_time = new Date();
    player_hours = player_time.getHours();
    player_minutes = player_time.getMinutes();
    player_total_minutes = player_minutes + player_hours*60;

    time_difference = Math.abs(player_total_minutes - server_minutes);
    // this calculation is for the time difference when one time is around 23:xx and the other is around 00:xx
    [low, high] = [server_minutes, player_total_minutes].sort(function(a,b){return a-b;});

    if(time_difference > 5 && (1440 - high) + low > 5){
      Bugsnag.notify("La hora del sistema en el bilbo " + board_slug + " no coincide con la hora del servidor\nHora del servidor: "+ server_time + "\nHora del sistema: " + addZero(player_hours) + ':' + addZero(player_minutes));
      return false;
    }
    return true
  }

  function timeUntilNextStart(){
    start_date = new Date($("#start_time").val());
    start_hours = start_date.getHours();
    start_minutes = start_date.getMinutes();

    current_time = new Date();
    current_hours = current_time.getHours();
    current_minutes = current_time.getMinutes();
    current_seconds = current_time.getSeconds();

    start_seconds = start_hours*3600 + start_minutes*60;
    current_seconds = current_hours*3600 + current_minutes*60+current_seconds;

    if (start_seconds < current_seconds) start_seconds += 86400; //+1 day in seconds
    return start_seconds - current_seconds;

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

 function addZero(i) {
   if (i < 10) {
     i = "0" + i;
   }
   return i;
 }

 function optimize_memory(rotation_key, board_slug){
   // you can type in console "arr = []; for(var i = 0; i < 80000000; i++) arr.push(i)" to increase memory usage. WARNING: if array size is too big, the page crashes
   try { //chheck if performance methods are integrated
     used_memory = performance.memory.usedJSHeapSize;
     memory_limit = performance.memory.jsHeapSizeLimit;
   } catch {
     performance_not_available(rotation_key, board_slug);
     return 0; //end here, the code that uses performance.memory wont be executed
   }
   if (used_memory/memory_limit < 0.70 ) return 0; //IF MEMORY IS MORE THAN 70%, REMOVE UNUSED MEDIA
   //GET ACTIVE CAMPAIGNS
   active_campaign_ids = get_active_campaign_ids(rotation_key);
  //GET MULTIMEDIA
   multimedia = $("[data-campaign-id]");
   //GET THE MULTIMEDIA THAT ISNT IN THE ADS ROTATION
   unused_multimedia = multimedia.filter(function(index, elem, arr){ return !active_campaign_ids.includes(parseInt(elem.getAttribute("data-campaign-id")));});
   delete_multimedia(unused_multimedia);
   if (used_memory/memory_limit <0.80 ) return 0; //IF MEMORY IS MORE THAN 80%, REMOVE SOME MEDIA FROM EACH CAMPAIGN
   //GET THE MULTIMEDIA THAT IS IN THE ADS ROTATION AND MAKE CUSTOM ACTIONS
   used_multimedia = multimedia.filter(function(index, elem, arr){ return active_campaign_ids.includes(parseInt(elem.getAttribute("data-campaign-id")));});
   keep_unique_multimedia_for_each_id(used_multimedia);
   if (used_memory/memory_limit > 0.9 ) Bugsnag.notify("El bilbo con slug " + board_slug+ " llegó al " + (used_memory/memory_limit*100).toFixed(1) + "% de memoria en uso.");
 }

 function performance_not_available(rotation_key, board_slug) {
   //GET ACTIVE CAMPAIGNS
   active_campaign_ids = get_active_campaign_ids(rotation_key);
   //GET MULTIMEDIA
   multimedia = $("[data-campaign-id]");
   //GET THE MULTIMEDIA THAT ISNT IN THE ADS ROTATION
   unused_multimedia = multimedia.filter(function(index, elem, arr){ return !active_campaign_ids.includes(parseInt(elem.getAttribute("data-campaign-id")));});
   delete_multimedia(unused_multimedia);
   //GET THE MULTIMEDIA THAT IS IN THE ADS ROTATION
   used_multimedia = multimedia.filter(function(index, elem, arr){ return active_campaign_ids.includes(parseInt(elem.getAttribute("data-campaign-id")));});
   used_videos = used_multimedia.filter(function(index, elem, arr){ return elem.tagName == 'VIDEO' });
   if( used_multimedia.length <= 100 && used_videos.length <= 30 ) return 0; //if some of this is false, keep optimizing
   keep_unique_multimedia_for_each_id(used_multimedia);
 }

 function get_active_campaign_ids(rotation_key) {
   //slice the array from current position of ads to the end of a array and then get unique elements, obviously remove "-" and "." to get only campaigns
   return $.parseJSON($("#ads_rotation").val()).slice(rotation_key)
            .filter(function(itm, i, a) { return i == a.indexOf(itm); })
            .filter(function(value, index, arr){ return value != "-" && value != ".";});
 }
 function delete_multimedia(multimedia) {
   //CUSTOM ACTIONS BEFORE DELETING VIDEOS
   $.each(multimedia, function( index, video ) {
     if (video.tagName != 'VIDEO') return;
     action_before_remove_video(video)
    });
    //DELETE ALL UNUSED MULTIMEDIA (IMAGES AND VIDEOS)
    multimedia.remove();
 }

 function keep_unique_multimedia_for_each_id(multimedia){
   //KEEP JUST ONE MULTIMEDIA FROM EACH ID
   multimedia = multimedia.sort(function(a,b){ return (a.tagName == 'VIDEO')? 1: -1 }); //place images first
   unique_multimedia_id = [];
   $.each(multimedia, function( index, elem ) {
     if (unique_multimedia_id.includes( elem.getAttribute("data-campaign-id") )){
       if (elem.tagName == 'VIDEO') action_before_remove_video(elem);
       elem.remove();
       return;
     }
     unique_multimedia_id.push(elem.getAttribute("data-campaign-id") )
    });
 }

 function action_before_remove_video(video) {
   video.pause();
   video.removeAttribute('src'); // empty source
   video.load();
 }
