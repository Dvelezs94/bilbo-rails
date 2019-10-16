class Campaign < ApplicationRecord
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
end
