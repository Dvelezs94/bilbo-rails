if ENV.fetch("RAILS_ENV") == "production"
  Rails.application.config.active_storage.service_urls_expire_in = 1.hour
else
  Rails.application.config.active_storage.service_urls_expire_in = 7.days
end
