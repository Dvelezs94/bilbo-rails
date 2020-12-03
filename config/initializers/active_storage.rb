if ENV.fetch("RAILS_ENV") {"development"} == "production"
  Rails.application.config.active_storage.service_urls_expire_in = 1.hour
else
  Rails.application.config.active_storage.service_urls_expire_in = 7.days
end
Rails.application.config.active_storage.previewers
