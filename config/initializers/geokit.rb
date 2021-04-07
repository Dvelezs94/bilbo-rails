# These defaults are used in Geokit::Mappable.distance_to and in acts_as_mappable
   Geokit::default_units = :miles # others :kms, :nms, :meters
   Geokit::default_formula = :sphere

   # This is the timeout value in seconds to be used for calls to the geocoder web
   # services.  For no timeout at all, comment out the setting.  The timeout unit
   # is in seconds.
   Geokit::Geocoders::request_timeout = 3

   # You can also use the free API key instead of signed requests
   # See https://developers.google.com/maps/documentation/geocoding/#api_key
   Geokit::Geocoders::GoogleGeocoder.api_key = ENV.fetch('MAPS_API_KEY')
