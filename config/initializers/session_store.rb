if Rails.env.production?
  Rails.application.config.session_store :cookie_store, :key => '_bilbo_session', :domain => "mybilbo.com"
else
  Rails.application.config.session_store :cookie_store, :key => '_bilbo_session', :domain => "lvh.me"
end
