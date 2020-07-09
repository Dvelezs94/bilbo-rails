class Board < ApplicationRecord
  include AdRotationAlgorithm
  include Rails.application.routes.url_helpers
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  belongs_to :project
  has_many :board_campaigns, class_name: "BoardsCampaigns"
  has_many :campaigns, through: :board_campaigns
  has_many :impressions
  has_many_attached :images
  has_one_attached :default_image
  before_save :generate_access_token, :if => :new_record?
  before_save :generate_api_token, :if => :new_record?
  enum status: { enabled: 0, disabled: 1 }
  enum social_class: { A: 0, AA: 1, AAA: 2, "AAA+": 3 }
  validates_presence_of :lat, :lng, :avg_daily_views, :width, :height, :address, :name, :category, :base_earnings, :face, :working_hours, on: :create
  after_create :generate_qr_code
  after_create :update_ad_rotation
  after_create :update_aspect_ratio
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

  # Get percentage occupied by active campaigns and minimum investment required to appear in the board
  def occupation
    begin
      rotation = JSON.parse(self.ads_rotation)
      # total places available
      rotation_size = rotation.size
      # free places for people to run ads
      free_places = rotation.group_by(&:itself).transform_values(&:count)["-"] || 1
      # regla de 3
      occupation = ((free_places * 100 / rotation_size) - 100).abs
      if occupation >= 95
        # campaign with lowest budget that is currently running
        lowest_running_campaign = rotation.group_by(&:itself).transform_values(&:count).except("-").sort_by { |key, value| value }.first[0]
        minimum_investment = Campaign.find(lowest_running_campaign).budget + 84 # 84 is a random number :)
      else
        minimum_investment = 50
      end
      {
        occupation: occupation,
        minimum_investment: minimum_investment
      }
    rescue
      {
        occupation: 0,
        minimum_investment: 50
      }
    end
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
    BoardsCampaigns.where(board_id: self, campaign_id: self.campaigns.active.pluck(:id)).approved.count
  end

  def campaign_of_day
    h = Impression.joins(:board, :campaign).where(board_id: self, created_at: Time.now.beginning_of_day..Time.now.end_of_day).group('campaigns.name').count
    h.sort_by { |key,value| h[key] = value.round(3) }
  end

  # get the maximum number of earnings based on base_price * 150%
  # this is so we charge 20% and they get 120% of the base earnings
  def calculate_max_earnings
    (base_earnings * 1.5)
  end

  # a cycle is the total time of an impression duration
  # example a cycle could be of 10 seconds
  # this gives the price of a cycle in a bilbo
  def cycle_price(date = Time.now)
    daily_seconds = working_hours * 3600
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
    campaigns.to_a.select(&:should_run?)
  end

  def update_ad_rotation
    # build the ad rotation because the ads changed
    new_cycle = self.build_ad_rotation
    self.update(ads_rotation: new_cycle)
  end


  private
  def update_aspect_ratio
    width = (self.width * 100).round(0)
    height = (self.height * 100).round(0)
    mcd = width.gcd(height)
    ar = (width/mcd).to_s + ":" + (height/mcd).to_s
    self.update!(aspect_ratio: ar)
  end

  def generate_access_token
    self.access_token = SecureRandom.hex
  end

  def generate_api_token
    self.api_token = SecureRandom.hex
  end

  # Provider functions

  # this function returns an array of the daily earnings by each board. This works on a monthly basis
  # Board.daily_provider_earnings_by_boards(@project, Time.now)
  def self.daily_provider_earnings_by_boards(project, time_range = 30.days.ago..Time.now)
    @daily_earnings = {}
    @impressions = Impression.joins(:board).where(boards: {project: project}, created_at: time_range)
    @impressions.group_by_day(:created_at).count.each do |key, value|
      @daily_earnings[key] = {impressions_count: value, gross_earnings: @impressions.group_by_day(:created_at).sum(:total_price)[key].round(3)}
    end
    @daily_earnings
  end

  def self.daily_provider_earnings_graph(project, time_range = 30.days.ago..Time.now)
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

  def generate_qr_code
    require 'rqrcode'

    qrcode = RQRCode::QRCode.new(root_url)

    # NOTE: showing with default options specified explicitly
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )
    self.update!(qr: Base64.encode64(png.to_s))
  end

  def to_s
    name
  end


end
