class SidekiqHeartbeatWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  require 'net/http'

  def perform
    if Rails.application.routes.default_url_options[:host] == "https://app.bilbo.mx"
      uri = URI.parse("https://push.statuscake.com/?PK=601279c17b2c83b&TestID=5739302&time=0")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.get(uri.request_uri)
    else
      true
    end
  end
end
