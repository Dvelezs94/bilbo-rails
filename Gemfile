source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3', '>= 4.3.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2', '>= 5.2.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.10'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.2', '>= 4.2.1'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Random data for seeds
  gem 'faker', '~> 2.13'
  gem 'factory_bot_rails', '~> 6.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'graphiql-rails'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'devise', '~> 4.6', '>= 4.6.2'
gem 'devise_invitable', '~> 2.0', '>= 2.0.1'
gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails', '~> 4.3', '>= 4.3.5'
gem 'feathericon-sass', '~> 1.0'
gem 'omniauth', '~> 1.9'
#Facebook login
gem 'omniauth-facebook', '~> 5.0'
# Google omniauth
gem 'omniauth-google-oauth2', '~> 0.6.1'
gem 'gravatar_image_tag', '~> 1.2'
gem "font-awesome-rails"
#Handle images
gem 'mini_magick', '~> 4.9', '>= 4.9.2'
# AWS sdk to support role based auth and s3 files
gem 'aws-sdk', '~> 3.0', '>= 3.0.1'
gem 'feathericon-rails', '~> 1.0'
gem 'material_icons', '~> 2.2', '>= 2.2.1'
gem 'friendly_id', '~> 5.2.4'
gem 'petergate', '~> 2.0', '>= 2.0.1'
gem 'active_storage_validations', '~> 0.7.1'
gem 'rails-jquery-steps', '~> 1.0'
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'
gem 'activemerchant', '~> 1.96'
gem 'sidekiq', '~> 6.0', '>= 6.0.7'
# be able to do group_by_date
gem 'groupdate', '~> 4.1', '>= 4.1.2'
gem 'clipboard-rails', '~> 1.7', '>= 1.7.1'
# nice looking alerts
gem 'data-confirm-modal', '~> 1.6', '>= 1.6.2'
gem 'kaminari', '~> 1.1', '>= 1.1.1'
gem 'bootstrap4-kaminari-views', '~> 1.0', '>= 1.0.1'
#autocomplete
gem 'rails-jquery-autocomplete', '~> 1.0', '>= 1.0.5'
gem 'chartkick', '~> 3.3', '>= 3.3.1'
gem 'haml', '~> 5.1', '>= 5.1.2'
gem 'animate.css-rails', '~> 3.2', '>= 3.2'
# Sendgrid API calls v3
gem 'sendgrid-ruby', '~> 5.3'
#APIs
gem 'graphql', '~> 1.10', '>= 1.10.6'
gem 'country_select', '~> 4.0'

gem 'bugsnag', '~> 6.13', '>= 6.13.1'
#rqrcode gems need
gem 'chunky_png', '~> 1.3', '>= 1.3.11'
gem 'rqrcode', '~> 1.1', '>= 1.1.2'
gem 'google-tag-manager-rails', '~> 0.1.3'

gem 'streamio-ffmpeg', '~> 3.0', '>= 3.0.2'

gem 'slack-notifier', '~> 2.3', '>= 2.3.2'
# Cron jobs
gem 'sidekiq-cron', '~> 1.2'
gem 'font-ionicons-rails', '~> 2.0', '>= 2.0.1.6'
gem 'blazer', '~> 2.2', '>= 2.2.6'
# facebook pixel
gem 'rack-tracker', '~> 1.12', '>= 1.12.1'
#forms
gem 'cocoon', '~> 1.2', '>= 1.2.9'
# pwa
gem 'serviceworker-rails', '~> 0.6.0'
# impersonate as another user
gem 'pretender', '~> 0.3.4'
gem 'invisible_captcha', '~> 1.1'
gem 'wicked_pdf', '~> 2.1'
gem 'wkhtmltopdf-binary', '~> 0.12.6.4'

gem 'geokit-rails', '~> 2.3', '>= 2.3.1'
gem 'timezone', '~> 1.3', '>= 1.3.9'

gem 'intl-tel-input-rails', '~> 12.3'
gem 'introjs-rails', '~> 1.0'
# Access an interactive console on exception pages or by calling 'console' anywhere in the code.
gem 'web-console', '>= 3.3.0'
# image thumbnails
gem 'image_processing', '~> 1.2'
# APM
gem 'skylight', '~> 4.3', '>= 4.3.2'
gem 'punching_bag', '~> 0.7.0'
gem 'rubyzip', '~> 2.3'
#amoeba for copy_campaign
gem 'amoeba', '~> 3.1'
gem 'clicksend_client', '~> 1.0', '>= 1.0.2'
# File uploads to S3
gem 'carrierwave', '~> 2.2'
gem 'fog-aws', '~> 3.8'
gem 'shrine', '~> 3.3'
# grape for Api
gem 'grape', '~> 1.5', '>= 1.5.3'
gem 'aws-sdk-s3', '~> 1'
gem 'mailerlite', '~> 1.13'
gem 'sitemap_generator', '~> 6.1', '>= 6.1.2'