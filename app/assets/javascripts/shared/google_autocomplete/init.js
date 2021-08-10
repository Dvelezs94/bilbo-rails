$(document).on('turbolinks:load', function() {
  initGoogleAutocomplete("search_autocomplete", "lat", "lng", "address_name", "", "1", false, "bilbomap");
});


//HELP FUNCTIONS
function updateMap(autocomplete, input, map) {
  place = autocomplete.getPlace();
  if (place.geometry) {
    map.panTo(place.geometry.location);
    map.setZoom(14);
  } else {
    input.value = '';
  }
}

//the three hidden input are created by the function, you just have to specify their new ids
function initGoogleAutocomplete(input_id, lat_name, lng_name, address_name, model, id_sufix, send_on_select = false, map_id = "") {
  waitForElement("#" + input_id, function() {
    //https://developers-dot-devsite-v2-prod.appspot.com/maps/documentation/javascript/examples/places-autocomplete-hotelsearch?hl=es-419
    //customize autocomplete
    var search_input = document.getElementById(input_id);
    var Gkey = "<%= ENV.fetch('GOOGLE_MAP_API') %>";
    var options = {
      // componentRestrictions: {country: "mx"}
    };
    //generate ids
    var lat_id = lat_name + id_sufix;
    var lng_id = lng_name + id_sufix;
    var address_id = address_name + id_sufix;
    //init autocomplete
    var search_autocomplete = new google.maps.places.Autocomplete(search_input, options);
    //change values when autocomplete changes
    google.maps.event.addListener(search_autocomplete, 'place_changed', function() {
      getLatAndLng(this, address_id, lat_id, lng_id);
    });
    //create hidden fields where coordinates are stored
    if ($("#" + lat_id).length == 0) { //just do it once (fix turbolinks problem)
      if (model != "") {
        $(search_input).after("<input type='hidden' name=" + model + "[" + lat_name + "] id=" + lat_id + " value=" + (search_input.getAttribute('lat') || "") + ">" + "<input type='hidden' name=" + model + "[" + lng_name + "] id=" + lng_id + " value=" + (search_input.getAttribute('lng') || "") + ">" + "<input type='hidden' name=" + model + "[" + address_name + "] id=" + address_id + " value ='" + (search_input.getAttribute('address_name') || "") + "'>");
      } else {
        $(search_input).after("<input type='hidden' name=" + lat_name + " id=" + lat_id + " value=" + (search_input.getAttribute('lat') || "") + ">" + "<input type='hidden' name=" + lng_name + " id=" + lng_id + " value=" + (search_input.getAttribute('lng') || "") + ">" + "<input type='hidden' name=" + address_name + " id=" + address_id + " value ='" + (search_input.getAttribute('address_name') || "") + "'>");
      }
    }
    window.id_sufix++; //prevents same ids on different autocomplete inputs
    //init map if id given if doesnt exist
    if (map_id != "") {
      if($("#"+map_id).length == 0){
      var map = new google.maps.Map(document.getElementById(map_id), {
        center: {
          lat: 19.432608,
          lng: -99.133209
        },
        zoom: 2,
      });
    }
      //change map when autocomplete changes
      search_autocomplete.addListener('place_changed', function() {
        updateMap(this, search_input, window.bilbomap);
      });

    }
    //extra events
    if (send_on_select) {
      search_autocomplete.addListener('place_changed', function() {
        $(search_input).closest("form").find("input[type='submit']").click();
      });
      //erase value lat and lng if nothing was selected before send form
      $(search_input).on("keydown", function(e) {
        if (e.keyCode == 13 && !search_input.value) {
          document.getElementById(lat_id).value = "";
          document.getElementById(lng_id).value = "";
        }
      });

    }
  }); //end of waitForElement
}
function getLatAndLng(autocomplete, address_name_id, lat_name_id, lng_name_id) {
  place = autocomplete.getPlace();
  document.getElementById(address_name_id).value = place.formatted_address;
  document.getElementById(lat_name_id).value = place.geometry.location.lat();
  document.getElementById(lng_name_id).value = place.geometry.location.lng();
}

function waitForElement(elementPath, callBack, times = 0) {
  timeout = setTimeout(function() {
    if ($(elementPath).length) {
      callBack(elementPath, $(elementPath));
    }
    else if (times == 10) {
      clearTimeout(timeout)
    }
    else {
      waitForElement(elementPath, callBack, times+1);
    }
  }, 500)
}