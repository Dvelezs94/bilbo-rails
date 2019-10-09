class Board < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  belongs_to :user
  has_and_belongs_to_many :campaigns
  has_many :impressions
  has_many_attached :images
  before_save :generate_token, :if => :new_record?
  enum status: { in_review: 0, enabled: 1, disabled: 2, banned: 3}
  validates_presence_of :user_id, :lat, :lng, :avg_daily_views, :width, :height, :duration, :address, :name, :category, :base_earnings, :face, on: :create

  # function to get only 1 marker per position, otherwise markercluster displays a cluster marker in the position
  # and the user is not able to click the marker because it is a cluster
  def self.get_map_markers
    self.enabled.select(:lat, :lng).as_json(:except => :id).uniq
  end

  # Get the total impressions starting from a certain date
  def impressions_count(start = 4.weeks.ago)
    impressions.where(created_at: start..Time.zone.now).sum(:cycles)
  end

  # Get the total impressions from a certain month
  def monthly_impressions_count(start = Time.now)
    impressions.where(created_at: start.beginning_of_month..start.end_of_month).sum(:cycles)
  end

  # a cycle is the total time of an impression duration
  # this gives the price of a cycle in a bilbo
  def cycle_price(date)
    daily_seconds = 86400
    total_days_in_month = date.end_of_month.day
    # this is 100% of possible earnings in the month
    total_monthly_possible_earnings = base_earnings * (10.0/7)
    (total_monthly_possible_earnings / (daily_seconds * total_days_in_month)) * duration
  end

  def streaming_state
    "streaming"
  end

  def active_campaigns
    campaigns.approved.where(state: true)
  end

  private

  def generate_token
    self.access_token = SecureRandom.hex
  end

end
