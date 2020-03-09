class Board < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  belongs_to :user
  has_and_belongs_to_many :campaigns
  has_many :impressions
  has_many_attached :images
  before_save :generate_access_token, :if => :new_record?
  before_save :generate_api_token, :if => :new_record?
  enum status: { in_review: 0, enabled: 1, disabled: 2, banned: 3}
  validates_presence_of :lat, :lng, :avg_daily_views, :width, :height, :duration, :address, :name, :category, :base_earnings, :face, on: :create

  # slug candidates for friendly id
  def slug_candidates
    [
      :name,
      [:name, :address]
    ]
  end

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

  def monthly_earnings(start = Time.now)
    cycle_price(start) * monthly_impressions_count(start)
  end

  # get the maximum number of earnings based on base_price * 140%
  def calculate_max_earnings
    base_earnings * (10.0/7)
  end

  # a cycle is the total time of an impression duration
  # example a cycle could be of 10 seconds
  # this gives the price of a cycle in a bilbo
  def cycle_price(date = Time.now)
    daily_seconds = 86400
    total_days_in_month = date.end_of_month.day
    # this is 100% of possible earnings in the month
    total_monthly_possible_earnings = calculate_max_earnings
    (total_monthly_possible_earnings / (daily_seconds * total_days_in_month)) * duration
  end

  # Check if there are Action cable connections in place
  def connected?
    Redis.new(url: ENV.fetch("REDIS_URL_ACTIONCABLE")).pubsub("channels", slug)[0].present?
  end

  # Returns how many times a single board should play it
  def rep_times(campaign)
    cycle_price(DateTime.now)
  end

  def active_campaigns
    campaigns.approved.where(state: true)
  end

  private

  def generate_access_token
    self.access_token = SecureRandom.hex
  end

  def generate_api_token
    self.api_token = SecureRandom.hex
  end
end
