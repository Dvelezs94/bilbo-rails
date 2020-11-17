require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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
    # enable web console for all envs
    config.web_console.development_only = false
  end
end
