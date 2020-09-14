module ShortenerHelper
  include Rails.application.routes.url_helpers

  # shortens a link and returns the token, then you can use it like shorten_url(shorten_link("link.com"))
  # very useful when we don't want to send super long URLs, like the metrics
  # e.g. @link = shorten_url(shorten_link(nalytics_campaign_url(@campaign)))
  def shorten_link(target_url)
    @shortener = Shortener.where(target_url: target_url).first_or_create
    return "#{shorten_url(@shortener.token)}"
  end
end
