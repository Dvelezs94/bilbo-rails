class Board < ApplicationRecord
  include AdRotationAlgorithm
  include BroadcastConcern
  include Rails.application.routes.url_helpers
  extend FriendlyId
  attr_accessor :new_ads_rotation, :admin_edit
  friendly_id :slug_candidates, use: :slugged
  belongs_to :project
  has_many :board_campaigns, class_name: "BoardsCampaigns"
  has_many :campaigns, through: :board_campaigns
  has_many :impressions
  validate :dont_edit_online, if: :connected?
  has_many_attached :images
  has_many_attached :default_images
  before_save :generate_access_token, :if => :new_record?
  before_save :generate_api_token, :if => :new_record?
  enum status: { enabled: 0, disabled: 1 }
  enum social_class: { A: 0, AA: 1, AAA: 2, "AAA+": 3 }
  validates_presence_of :lat, :lng, :utc_offset,:avg_daily_views, :width, :height, :address, :name, :category, :base_earnings, :face, :start_time, :end_time, on: :create
  after_create :generate_qr_code
  after_create :update_ads_rotation
  before_create :calculate_aspect_ratio
  before_save  do
    if width_changed? || height_changed?
      calculate_aspect_ratio
    end
  end
  scope :images_only, -> { where(images_only: true) }

  ################ DEMO FIX ##########################
  def start_time
    super.nil?? Time.parse("8:00")  : super
  end
  def end_time
    super.nil?? Time.parse("2:00")  : super
  end
  def utc_offset
    super.nil?? 0  : super
  end
  ###################################################

  def di_images
    default_images.select(&:image?)
  end

  def di_videos
    default_images.select(&:video?)
  end

  # slug candidates for friendly id
  def slug_candidates
    [
      ["bilbo", :name],
      ["bilbo", :name, :address]
    ]
  end

  def self.search(search_board)
    if search_board
      where('lower(name) LIKE ?', "%#{search_board.downcase}%")
    else
      all
    end
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
    @chosen_month = Time.zone.now.beginning_of_month
    @start_date = @chosen_month - 1.month + 25.days
    @end_date = @chosen_month + 25.days
    impressions.where(created_at: @start_date..@end_date).sum(:cycles)
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
      @chosen_month = Time.zone.now.beginning_of_month
      @start_date = @chosen_month - 1.month + 25.days
      @end_date = @chosen_month + 25.days
      impressions.where(created_at: @start_date..@end_date).sum(:total_price)
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

  # get the maximum number of earnings based on base_price + extra earnings percentage form the provider
  # this is so we charge 20% and they get their corresponding extra % of the base earnings
  def calculate_max_earnings(bilbo_percentage: 20)
    # (base_earnings * 1.5)
    bilbo_percentage_earnings = bilbo_percentage/100.0
    provider_extra_percentage = extra_percentage_earnings/100.0
    (base_earnings * ((1+provider_extra_percentage)/(1-bilbo_percentage_earnings))).round(2)
  end

  # a cycle is the total time of an impression duration
  # example a cycle could be of 10 seconds
  # this gives the price of a cycle in a bilbo
  def cycle_price(date = Time.now)
    daily_seconds = working_minutes(start_time, end_time) * 60
    total_days_in_month = date.end_of_month.day
    # this is 100% of possible earnings in the month
    total_monthly_possible_earnings = calculate_max_earnings
    (total_monthly_possible_earnings / (daily_seconds * total_days_in_month)) * duration
  end

  # Check if there are Action cable connections in place
  def connected?
    Redis.new(url: ENV.fetch("REDIS_URL_ACTIONCABLE")).pubsub("channels", slug)[0].present?
  end

  def dont_edit_online
    #new ad rotation nil
    errors.add(:base, "No puedes editar un bilbo en línea") if admin_edit
  end

  # Returns how many times a single board should play it
  def rep_times(campaign)
    cycle_price(DateTime.now)
  end

  # Return campaigns active
  def active_campaigns(type="all")
    if type == "all"
      campaigns.select{ |c| c.should_run?(self.id) }
    elsif type == "provider"
      campaigns.where(provider_campaign: true).select{ |c| c.should_run?(self.id) }
    elsif type == "no_provider"
      campaigns.where(provider_campaign: false).select{ |c| c.should_run?(self.id) }
    end
  end

  def broadcast_to_board(camp, force_generate = false, make_broadcast = true)
    if camp.provider_campaign
      err = update_ads_rotation(force_generate)
      return err if err.present?
    end
    update_campaign_broadcast(camp) if make_broadcast
    return []
  end

  def update_ads_rotation(force_generate = false)
    err = self.build_ad_rotation if self.new_ads_rotation.nil? || force_generate  #in campaigns this is generated in validation, so it doesnt need to do again
    return err if err.present?
    self.ads_rotation = self.new_ads_rotation
    @success = self.save
    return self.errors if !@success
    return []
  end

  def update_campaign_broadcast(camp)
    if camp.should_run?(self.id)
      publish_campaign(camp.id, self.id)
    else
      remove_campaign(camp.id, self.id)
    end
  end

  def size_change
    if self.aspect_ratio.split(':')[0].to_f > self.aspect_ratio.split(':')[1].to_f
      m=self.aspect_ratio.split(':')[0].to_f
      @new_height = (self.aspect_ratio.split(':')[0].to_f/m)*250
      @new_width = (self.aspect_ratio.split(':')[1].to_f/m)*250
    else
      m = self.aspect_ratio.split(':')[1].to_f
      @new_height = (self.aspect_ratio.split(':')[0].to_f/m)*250
      @new_width = (self.aspect_ratio.split(':')[1].to_f/m)*250
    end
    return @new_width, @new_height
  end
  def working_hours(st,et, zero_if_equal = false) #returns hours of difference
    working_minutes(st,et,zero_if_equal)/60.0
  end

  def ads_rotation_with_start_time
    st = time_h_m_s(start_time)
    {st => ads_rotation}.to_h
  end

  def ads_rotation_hash(rot)
    output = {}
    rot.each_with_index do |name, idx|
      current_time = start_time + (10*idx).seconds
      output[time_h_m_s(current_time)] = name
    end
    return output
  end

  def working_minutes(st,et, zero_if_equal = false) #returns minutes of difference
    # if end time is less than the start time, i assume that the board is on until the next day
    # if they are equal i assume is all day on
    start_hours = st.strftime("%H").to_i
    start_mins = st.strftime("%M").to_i
    start_mins = start_hours * 60 + start_mins
    end_hours = et.strftime("%H").to_i
    end_mins = et.strftime("%M").to_i
    end_mins = end_hours * 60 + end_mins
    end_mins = end_mins + 1440 if end_mins < start_mins
    end_mins = end_mins + 1440 if !zero_if_equal && end_mins == start_mins # 1440 are the minutes in a day
    (end_mins - start_mins)
  end
  def time_h_m_s(time)
    time.strftime("%H:%M:%S")
  end

  # Get the pixel size for correct image fit in the bilbo
  def recommended_image_size
    resolution = 1080
    # aspect ratio width and height
    arw = aspect_ratio.split(":")[0].to_i
    arh = aspect_ratio.split(":")[1].to_i
    # here we asume that we want all pictures to be FHD (1080p)
    imgw = ((arw * resolution) / arh).to_i
    return "#{imgw}x#{resolution}"
  end

  private
  def total_cycles(st,et,zero_if_equal = false )
    working_minutes(st,et,zero_if_equal)*6
  end

  def calculate_aspect_ratio
    width = (self.width * 100).round(0)
    height = (self.height * 100).round(0)
    mcd = width.gcd(height)
    ar = (width/mcd).to_s + ":" + (height/mcd).to_s
    self.aspect_ratio = ar
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

  #this method returns the monthly earnings of a board, we use it on the provider_statistics
  def self.monthly_earnings_by_board(project, time_range = 30.days.ago..Time.now)
    @monthly_earnings = Impression.joins(:board).where(boards: {project: project},created_at: time_range).sum(:total_price).round(3)
  end

  def self.monthly_impressions(project,time_range = 30.days.ago..Time.now)
    @monthly_impressions = Impression.joins(:board).where(boards: {project: project},created_at: time_range).sum(:cycles)
  end

  def self.daily_provider_earnings_graph(project, time_range = 30.days.ago..Time.now)
  h = Impression.joins(:board).where(boards: {project: project}, created_at: time_range).group_by_day(:created_at).sum(:total_price)
      h.each { |key,value| h[key] = value.round(3) }
end


  # this function returns an array of the top campaigns. This works on a monthly basis
  # Board.top_campaigns(@project, Time.now)
  # Board.top_campaigns(@board, Time.now)
  def self.top_campaigns(id, time_range = 30.days.ago..Time.now, type = 1)
    model = Impression.arel_table
    if type == 1
      h = Impression.joins(:campaign, :board).where(boards: {project: id}, created_at: time_range).group('campaigns.name').pluck("campaigns.name", model[:id].count, model[:total_price].sum)
    end
    if type == 2
      h = Impression.joins(:campaign, :board).where(board_id: id, created_at: time_range).group('campaigns.name').pluck("campaigns.name", model[:id].count, model[:total_price].sum)
    end
    h.sort_by{|n, c, s| -c}
  end
  # End provider functions

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
