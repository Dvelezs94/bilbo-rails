class Board < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  belongs_to :project
  has_many :board_campaigns, class_name: "BoardsCampaigns"
  has_many :campaigns, through: :board_campaigns
  has_many :impressions
  has_many_attached :images
  before_save :generate_access_token, :if => :new_record?
  before_save :generate_api_token, :if => :new_record?
  enum status: { enabled: 0, disabled: 1}
  validates_presence_of :lat, :lng, :avg_daily_views, :width, :height, :duration, :address, :name, :category, :base_earnings, :face, on: :create

  # slug candidates for friendly id
  def slug_candidates
    [
      ["bilbo", :name],
      ["bilbo", :name, :address]
    ]
  end

  # function to get only 1 marker per position, otherwise markercluster displays a cluster marker in the position
  # and the user is not able to click the marker because it is a cluster
  def self.get_map_markers
    enabled.select(:lat, :lng).as_json(:except => :id).uniq
  end

  # Get the total impressions starting from a certain date
  def impressions_count(start = 4.weeks.ago)
    impressions.where(created_at: start..Time.zone.now).sum(:cycles)
  end

  # Get the total impressions from a certain month
  def monthly_impressions_count(start = Time.now)
    impressions.where(created_at: start.beginning_of_month..start.end_of_month).sum(:cycles)
  end

  def daily_impressions_count(day = Time.now)
    time_range = day.beginning_of_day..day.end_of_day
    impressions.where(created_at: time_range).sum(:cycles)
  end

  def daily_earnings(day = Time.now)
    time_range = day.beginning_of_day..day.end_of_day
    cycle_price(day) * daily_impressions_count(day)
  end

  def monthly_earnings(start = Time.now)
      impressions.where(created_at: start.beginning_of_month..start.end_of_month).sum(:total_price)
  end

  def impressions_single
    self.impressions.where(created_at: 3.months.ago..Time.now).group_by_day(:created_at).count
  end

  def daily_earnings(time_range = 3.months.ago..Time.now )
    h = impressions.where(board_id: self, created_at: time_range ).group_by_day(:created_at).sum(:total_price)
    h.each { |key,value| h[key] = value.round(3) }
  end

  #Return the number of active campaigns in the board
  def approved_campaign_by_board
    board_campaigns.approved.count
  end

  def campaign_of_day
    h = Impression.joins(:board, :campaign).where(board_id: self, created_at: Time.now.beginning_of_day..Time.now.end_of_day).group('campaigns.name').count
    h.sort_by { |key,value| h[key] = value.round(3) }
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

  # Return campaigns active
  def active_campaigns
    Campaign.where(id: board_campaigns.approved.pluck(:campaign_id)).active
  end

  private

  def generate_access_token
    self.access_token = SecureRandom.hex
  end

  def generate_api_token
    self.api_token = SecureRandom.hex
  end

  # Provider functions

  # this function returns an array of the daily earnings by each board. This works on a monthly basis
  # Board.daily_provider_earnings_by_boards(@project, Time.now)
  def self.daily_provider_earnings_by_boards(project, time_range = 30.days.ago..Time.now, type = 1)
    h = Impression.joins(:board).where(boards: {project: project}, created_at: time_range).group_by_day(:created_at).sum(:total_price)
    h.each { |key,value| h[key] = value.round(3) }
  end


  # this function returns an array of the top campaigns. This works on a monthly basis
  # Board.top_campaigns(@project, Time.now)
  # Board.top_campaigns(@board, Time.now)
  def self.top_campaigns(id, time_range = 30.days.ago..Time.now, type = 1)
    if type == 1
        h = Impression.joins(:campaign, :board).where(boards: {project: id}, created_at: time_range).group('campaigns.name').count
    end
    if type == 2
        h = Impression.joins(:campaign, :board).where(board_id: id, created_at: time_range).group('campaigns.name').count
    end
    h.sort_by {|k, v| -v}
  end
  # End provider functions

  private

  def to_s
    name
  end


end
