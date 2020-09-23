class CampaignSubscriber < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ShortenerHelper
  include ApplicationHelper
  include ActionView::Helpers
  # campaign subscribers are people that will get SMS/Whatsapp messages with
  # notifications regarding their referenced campaign
  belongs_to :campaign
  validates_uniqueness_of :phone, scope: :campaign_id
  validates_length_of :phone, minimum: 11, maximum: 13
  validates :phone, format: { with: /\A\+\d{1,3}\d{10}\z/, message: I18n.t("validations.only_numbers_for_phone") }
  validate :max_number_of_subscribers
  after_create :send_welcome_sms

  def first_name
    name.split[0]
  end

  private
  # allow a maximum of 3 subscribers per campaign
  def max_number_of_subscribers
    errors.add(:base, "#{I18n.t('campaign.subscribers.maximum_number_reached')}") if self.campaign.subscribers.count >= 3
  end

  def send_welcome_sms
    send_sms(phone, "Te han registrado para la campaña #{truncate(campaign.name, length: 18)} link: #{shorten_link(analytics_campaign_url(campaign.slug))}")
  end
end
