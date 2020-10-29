require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Configure the geonames api for the timezone gem
Timezone::Lookup.config(:geonames) do |c|
  c.username = ENV.fetch("GEONAMES_USER") {"carlos0914"} # <-- username for geonames.org
  c.offset_etc_zones = true
end
#Note: The google api can also be used here, some people use the
#google api when geonames fails or reaches the credit limit


module Bilbo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # default time zone
    config.time_zone = ENV.fetch("TIME_ZONE") { "Mexico City" }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.i18n.default_locale = ENV.fetch("RAILS_LOCALE") { :en }.to_sym
    #Set the error pages routes
    config.exceptions_app = self.routes
  end
end
