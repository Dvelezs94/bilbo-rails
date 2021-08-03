$(document).on('turbolinks:load', function() {
    if ($("#landing-map-frame").length > 0){
        google.maps.event.addDomListener(window, 'turbolinks:load', initializeLandingMap);

        // just in case map doesn't load initially, retry until it does
        var map_load_interval = setInterval(function(){
        //console.log("attempting to load map");
        if (typeof google === 'object' && typeof google.maps === 'object') {
            console.log("map has loaded so im not retrying anymore");
            clearInterval(map_load_interval);
        } else {
            initializeLandingMap();
        }
        }, 1500)
    }
});

function initializeLandingMap() {
    waitForElement("#landing-map-frame", function() {
      var mapLat = $("#bilboLat").val()
      var mapLng = $("#bilboLng").val()
  
      // center of mexico
      var center = new google.maps.LatLng(mapLat, mapLng);
      var zoom = 15
  
      window.landingbilbomap = new google.maps.Map(document.getElementById('landing-map-frame'), {
        zoom: zoom,
        center: center,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        styles: [{"featureType":"all","elementType":"labels.text.fill","stylers":[{"color":"#7c93a3"},{"lightness":"-10"}]},{"featureType":"administrative.country","elementType":"geometry","stylers":[{"visibility":"on"}]},{"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#a0a4a5"}]},{"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#62838e"}]},{"featureType":"landscape","elementType":"geometry.fill","stylers":[{"color":"#dde3e3"}]},{"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#3f4a51"},{"weight":"0.30"}]},{"featureType":"poi","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"poi.attraction","elementType":"all","stylers":[{"visibility":"on"}]},{"featureType":"poi.business","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.government","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"all","stylers":[{"visibility":"on"}]},{"featureType":"poi.place_of_worship","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.school","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.sports_complex","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"all","stylers":[{"saturation":"-100"},{"visibility":"on"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"visibility":"on"}]},{"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#bbcacf"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"lightness":"0"},{"color":"#bbcacf"},{"weight":"0.50"}]},{"featureType":"road.highway","elementType":"labels","stylers":[{"visibility":"on"}]},{"featureType":"road.highway","elementType":"labels.text","stylers":[{"visibility":"on"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.stroke","stylers":[{"color":"#a9b4b8"}]},{"featureType":"road.arterial","elementType":"labels.icon","stylers":[{"invert_lightness":true},{"saturation":"-7"},{"lightness":"3"},{"gamma":"1.80"},{"weight":"0.01"}]},{"featureType":"transit.line","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#a3c7df"}]},{ "featureType": "road.arterial", "elementType": "labels", "stylers": [ { "visibility": "off" } ] }],
        disableDefaultUI: true,
        zoomControl: false,
      });

      new google.maps.Marker({
        position: center,
        map: window.landingbilbomap,
        title: $("#bilboName").html()
      });    
    });
  }