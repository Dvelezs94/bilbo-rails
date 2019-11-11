class Campaign < ApplicationRecord
  include ActionView::Helpers::DateHelper
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user
  has_many :impressions
  belongs_to :ad, optional: true
  has_and_belongs_to_many :boards
  # status is for internal status, like in review, accepted or denied
  enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3, deleted: 4 }

  # 'state' is for user desired state of the campaign, enabled or disabled

  # Trigger broadcast or remove campaign
  before_update :update_broadcast
  before_destroy :remove_campaign

  validates :name, presence: true
  # validates :ad, presence: true, on: :update
  validate :state_change_time, on: :update,  if: :state_changed?
  validate :cant_update_when_active
  validate :validate_ad_stuff, on: :update
  after_validation :return_to_old_state_id_invalid
  before_save :update_state_updated_at, if: :state_changed?
  before_save :set_in_review, :if => :ad_id_changed?

  def total_invested
    # self.orders.sum(:total)
    true
  end

  def ongoing?
    # validates if both fields are complete
    !(self.starts_at? && self.ends_at?)
  end

  # Function to know if the campaign has multimedia files in the ad
  def has_multimedia?
    ad.present? && ad.multimedia.first.present?
  end

  def set_in_review
    self.status = "in_review"
  end

  # function that checks if the value of attributes changed
  # after check it trigger the proper function to add or remove campaign from boards
  def update_broadcast
    if status_changed? || state_changed?
      if approved? && state.present?
        publish_campaign
      else
        remove_campaign
      end
    end
  end

  # Publish ad function, this gets triggered when the state and status are true
  def publish_campaign
    AdBroadcastWorker.perform_async(self.id, "enable")
  end

  # Remove ad function, this gets triggered when the state or status are false
  def remove_campaign
    AdBroadcastWorker.perform_async(self.id, "disable")
  end

  def state_change_time
    # Value for state to be changed on prod every 2 minutes
    minutes_needed = (ENV["RAILS_ENV"] == "development")? 0.1.minutes : 2.minutes
    #if state_updated_at is nil, is the first time they update
    time_elapsed = (state_updated_at.present?)? ((Time.now - state_updated_at)/1.minutes).minutes : minutes_needed
    errors.add(:base, "#{I18n.t ('campaign.wont_be_able_to_update_state')} #{distance_of_time_in_words( (minutes_needed - time_elapsed).ago, Time.now, include_seconds: true )}") if (time_elapsed < minutes_needed)
  end

  def validate_ad_stuff
    if self.ad.nil?
      errors.add(:base, I18n.t('campaign.errors.no_ad'))
      return
    end
    errors.add(:base, I18n.t('campaign.errors.no_multimedia')) if self.ad.multimedia.empty?
    errors.add(:base, I18n.t('campaign.errors.ad_deleted')) if self.ad.deleted?
  end

  def state_changed_to_true?
    self.state
  end

  #used to return the old state of the object and display the correct error (if this is not set the state has desired value even if validation fails)
  def return_to_old_state_id_invalid
    self.state = !self.state if state_changed? && self.errors.any?
  end

  def update_state_updated_at
    self.state_updated_at = Time.now
  end

  def cant_update_when_active
    if self.state_was && !state_changed?
      #this can pass when someone is passing campaign to false and also updating other attributes, but i dont think now that will cause problems
      #something is changing when state is active, so i raise error
      errors.add(:base, I18n.t('campaign.errors.cant_update_when_active'))
    end
  end
end
