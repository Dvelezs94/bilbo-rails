class Board < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  belongs_to :user
  has_and_belongs_to_many :campaigns
  has_many :impressions
  has_many_attached :images
  enum status: { enabled: 0, disabled: 1, banned: 2}
  enum face: {
    north: 0,
    south: 1,
    east: 2,
    west: 3
  }

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
    campaigns.where(state: true).length
  end

end
