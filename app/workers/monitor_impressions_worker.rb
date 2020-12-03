class MonitorImpressionsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    yesterday_impressions = Impression.where(created_at: (1.day.ago - 1.hour)..1.day.ago).size.to_f
    today_impressions = Impression.where(created_at: 1.hour.ago..Time.zone.now).size.to_f
    send_alert = false

    # impressions should be above 500 by 12 PM
    if today_impressions < 500
      send_alert = true
    # if impressions are under 60% compared to yesterday, something is wrong
    elsif (today_impressions / yesterday_impressions) < 0.6
      send_alert = true
    end

    # Send slack alert
    if Rails.env.production? && send_alert
      SlackNotifyWorker.perform_async("ALERTA: Pocas impresiones comparadas con el día de ayer. revisar #{Rails.env}")
    end
  end
end
