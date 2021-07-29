class Campaign < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper
  include BroadcastConcern
  include ShortenerHelper
  include ProjectConcern
  include ReviewBoardCampaignsConcern
  extend FriendlyId
  attr_accessor :owner_updated_campaign, :content_ids, :budget_distribution, :skip_review, :user_locale
  friendly_id :slug_candidates, use: :slugged
  belongs_to :project
  has_many :impressions
  has_many :campaign_denials
  has_many :impression_hours
  accepts_nested_attributes_for :impression_hours, reject_if: :all_blank, allow_destroy: true
  belongs_to :ad, optional: true
  has_many :board_campaigns, class_name: "BoardsCampaigns", before_add: :set_budget
  has_many :boards, through: :board_campaigns
  has_many :provider_invoices
  has_many :witnesses, dependent: :delete_all
  validate :duration_multiple_of_10, if: :duration_changed?
  validate :duration_multiple_of_10, on: :create
  validate :valid_active_time, on: :create
  amoeba do
    enable
    include_association :impression_hours, if: :is_per_hour?
    include_association :boards, through: :board_campaigns
    include_association :board_campaigns, class_name: "BoardsCampaigns"
  end

  def slug_candidates
    [
      [:name, :friendly_uuid]
    ]
  end

  # instead of doing campaign.campaign_subscribers you can do campaign.subscribers
  alias_attribute :subscribers, :campaign_subscribers
  has_many :campaign_subscribers

  # status is for the
  enum status: { active: 0, inactive: 1 }
  enum classification: {budget: 0, per_minute: 1, per_hour: 2}
  enum objective: {awareness: 0, interaction: 1, conversion: 2} #conversion is still not there, we need the pixel

  # 'state' is for user desired state ser by the user, enabled or disabled

  # Trigger broadcast or remove campaign
  before_destroy :remove_campaign

  #valid prices of the bilbo steps
  validate :validate_price_steps, if: :is_per_budget?
  validates :name, presence: true
  validates :provider_campaign, inclusion: [true, false]
  #validates :ad, presence: true, on: :update
  validate :validate_content, on: :update, if: :contents_present?
  validate :project_enabled?
  # validate :state_change_time, on: :update,  if: :state_changed?
  validate :check_user_verified, on: :update,  if: :state_changed?
  validate :cant_update_when_active, on: :update
  #validate :validate_ad_stuff, on: :update
  #validate :ad_processed, on: :update
  validate :test_for_valid_settings
  validate :check_build_ad_rotation, if: :provider_campaign
  validates :link, format: URI::regexp(%w[http https]), allow_blank: true
  after_validation :return_to_old_state_id_invalid
  before_save :update_state_updated_at, if: :state_changed?
  before_save :notify_in_a_week, if: :ad_id_changed?
  before_update :set_in_review_and_update_price, unless: :skip_review
  before_update :update_budget
  after_commit :broadcast_to_all_boards
  after_commit :create_content, if: :contents_present?
  after_update :update_bc
  after_create :generate_shorten_url
  after_create :generate_external_link_shortener

  def owner
    self.project.owner
  end

  def true_duration(board_slug)
    if self.provider_campaign?
      return duration
    else
      return Board.friendly.find(board_slug).duration
    end
  end

  # Get the medium frecuency of the campaign per minute (1 impression every x minutes)
  def frequency
    running_days = impressions.group_by_day(:created_at).count.keys
    number_of_days = running_days.length
    total_minutes = boards.sum(&:working_minutes) * number_of_days
    freq = total_minutes.to_f / (impression_count * boards.count)
    freq.round(1)
  end

  def duration_multiple_of_10
    if (duration % 10) != 0 || duration <= 0 || duration > 60
      errors.add(:base, I18n.t('ads.errors.is_not_multiple_of_10'))
    end
  end

  def generate_shorten_url
    shorten_link(analytics_campaign_url(slug))
  end

  # get campaign shortener
  def qr_shortener
    Shortener.find_by_target_url(redirect_to_external_link_campaign_url(slug))
  end

  def generate_external_link_shortener
    shorten_link(redirect_to_external_link_campaign_url(slug))
  end

  def friendly_uuid
    SecureRandom.uuid
  end

  def self.running
    active.where(state: true)
  end

  def ongoing?
    # validates if both fields are complete
    !(self.starts_at? && self.ends_at?)
  end

  # Function to know if the campaign has multimedia files in the ad
  def has_multimedia?
   ad.present? && ad.multimedia.first.present?
  end

  def ad_processed
    if self.state_is_true? && has_multimedia? &&  !Ad.find(self.ad_id).processed?
      errors.add(:base, I18n.t('campaign.errors.processing_creatives'))
    end
  end

  # def have_to_set_in_review_on_boards
  #   return ad_id_changed? || budget_changed? || minutes_changed? || imp_changed? || hour_start_changed? || hour_finish_changed? || starts_at_changed? || ends_at_changed?
  # end

  def have_to_set_in_review_on_boards
    if provider_campaign
      return owner_updated_campaign
    else
      return ad_id_changed?
    end
  end

  def set_in_review_and_update_price
    set_in_review_boards_and_update_price(self, have_to_set_in_review_on_boards, owner_updated_campaign)
  end

  def project_status
    errors.add(:base, I18n.t('campaign.errors.no_images')) if self.project.status
  end

  # distribute budget evenly between all bilbos
  def budget_per_bilbo(board)
    if budget_distribution.present? #When editing a budget campaign we need to validate the new desired budget, not the one that is stored in the database
      dist = JSON.parse(budget_distribution)
      return dist["#{board.id}"].to_f
    else
      bc = BoardsCampaigns.find_by(campaign: self, board: board)
      return bc.present?? bc.budget : 0
    end
  end

  def check_build_ad_rotation(lang: user_locale || ENV.fetch("RAILS_LOCALE"))
    if ( state && state_changed? && !have_to_set_in_review_on_boards )
      boards.each do |b|
        if self.should_run?(b.id) && b.get_campaigns
          #In case no error is found
          #Build again the ad rotation and save it, only with the remaining impressions of the budget campaigns
          err2 = b.build_ad_rotation(self, lang)
          if err2.present?
            errors.add(:base, err2.first)
            break
          end
        end
      end
    end
  end

  def should_run?(board_id)
    #self.state check the state of campaign
    #self.status == "active" check the status of campaign
    #self.budget > 0 Check that the budget is greater than 0 of campaign
    brd = Board.find(board_id)
    if self.is_per_budget?
      if budget_distribution.present?
        dist = JSON.parse(budget_distribution)
        campaign_budget = dist["#{board_id}"].to_f
      else
        bc = BoardsCampaigns.find_by(campaign: self, board: brd)
        campaign_budget = bc.present?? bc.budget :  0.0
      end
    else
      campaign_budget = 0.0 #if campaign is not per budget we initialize this variable as 0 so it can be compared with the minimum_budget of the board
    end
    if self.status == "active" && self.state && campaign_active_in_board?(board_id) && time_to_run?(brd)
      if classification == "budget" && campaign_budget >= brd.minimum_budget && self.remaining_impressions(board_id) > 0 && (provider_campaign || project.owner.balance >= 5)
        return true
      elsif classification == "per_minute"
        return true
      elsif classification == "per_hour" && self.remaining_impressions(board_id) > 0 && (provider_campaign || project.owner.balance >= 5)
        return true
      end
    else
      return false
    end
  end

  def remaining_impressions(board_id)
    x = self.board_campaigns.find_by(board_id: board_id)
    x.present?? x.remaining_impressions: 0
  end

  def user_has_budget?
    #look for users with projects that have a balance greater than 5 credits and are the owner
    # if its provider then it doesnt need budget
    self.project.users[0].is_provider? || ProjectUser.where(project_id: project.id, role: "owner").joins(:user).where("balance > ?", 5 ).any?
  end

  def campaign_budget_spent?
    budget_spent= Impression.where(campaign:self, created_at: Date.today.beginning_of_day..Date.today.at_end_of_day).sum(:total_price)
    budget_spent >= self.budget
  end

  def campaign_active_in_board?(board_id)
    board_campaigns.approved.where(board_id: board_id).any?
  end

  def to_utc(time,utc_offset)
    time = (time + time.utc_offset).utc # keeps the same hour in utc zone Example: "03:25 -05:00" -> "03:25 +00:00"
                                        # this is useful because the timezone of the campaign can be different than
                                        # the timezone of the board, which is what we need
    time - utc_offset.minutes
  end

  def time_to_run?(brd)
    # if set start and end to august 4, it runs all august 4 day
    # if set from 4 aug to 5 aug, it runs entire both days
    (self.starts_at.nil? && self.ends_at.nil?) || (time_to_start_in_board(brd) <= 0 && time_to_end_in_board(brd) + 86400 > 0)
  end

  def time_to_start_in_board(board)
    campaign_starts_at = (self.starts_at + self.starts_at.utc_offset).utc
    real_start_time = campaign_starts_at - board.utc_offset.minutes
    #If this returns a negative value means the campaign has started, else this is the ammount of seconds remaining to start
    return (real_start_time - Time.now.utc).ceil
  end

  def time_to_end_in_board(board)
    campaign_ends_at = (self.ends_at + self.ends_at.utc_offset).utc
    real_end_time = campaign_ends_at - board.utc_offset.minutes
    #This is the remaining time in seconds for the end date of the campaign (start of day)
    #if we want the end of the day we just need to add 1 day (86400 seconds) to this value
    return (real_end_time - Time.now.utc).ceil
  end


  # See fi the current date is between start and end date
  def is_now_ongoing?
    begin
      if self.active?
        if DateTime.now.between?(self.starts_at, self.ends_at)
          true
        else
          false
        end
      else
        false
      end
    # if fails. then return false cuz the campaign doesn't have an end date
    # this is to prevent users from potentially doing bad stuff
    rescue
      false
    end
  end



  def broadcast_to_all_boards
    boards.each do |b|
      err = b.broadcast_to_board(self) if (board_campaigns.find_by(board: b).approved?) #make the broadcast only in the boards where the campaign is approved
      #currently no use for errors here
      b.update(occupation: b.new_occupation)
    end
  end

  def self.all_off #state active
    (self.select {|campaign| campaign.state}.length == 0)? true : false
  end

  def self.select_active #state active
    self.select {|campaign| campaign.state}
  end

  def off
    !self.state
  end

  def on
    self.state
  end

  def ready_to_update_state
    # Value for state to be changed on prod every 2 minutes
    if Rails.env.development?
      minutes_needed = 0.1.minutes
    elsif Rails.env.test?
      minutes_needed = 0.minutes
    else
      minutes_needed = 0.2.minutes
    end
    #if state_updated_at is nil, is the first time they update
    time_elapsed = (state_updated_at.present?)? ((Time.now - state_updated_at)/1.minutes).minutes : minutes_needed
    return (time_elapsed >= minutes_needed)
  end

  def validate_ad_stuff
    if self.ad.nil?
      errors.add(:base, I18n.t('campaign.errors.no_ad'))
      return
    end
    if boards.images_only.count > 0
      if !ad.has_images?
        errors.add(:base, I18n.t('campaign.errors.no_images'))
        return
      end
    end
    errors.add(:base, I18n.t('campaign.errors.no_multimedia')) if self.ad.multimedia.empty?
    errors.add(:base, I18n.t('campaign.errors.ad_deleted')) if self.ad.deleted?
  end

  def state_is_true?
    self.state
  end

  #used to return the old state of the object and display the correct error (if this is not set the state has desired value even if validation fails)
  def return_to_old_state_id_invalid
    self.state = !self.state if state_changed? && self.errors.any?
  end

  def update_state_updated_at
    self.state_updated_at = Time.now
  end

  # make sure the owner of the project is verified when enabling a campaign
  def check_user_verified
    if owner.is_user? && !owner.verified && state
      errors.add(:base, I18n.t('campaign.errors.verification_required'))
    end
  end

  def cant_update_when_active
    if self.state_was && !state_changed?
      #this can happen when someone is passing campaign to false and also updating other attributes, but i dont think now that will cause problems
      #something is changing when state is active, so i raise error
      errors.add(:base, I18n.t('campaign.errors.cant_update_when_active'))
    end
  end

  # Get total ammount of money invested on the campaign between dates
  def total_invested_range(start_date: 30.days.ago, end_date: Time.zone.now, board_id: nil)
    Impression.where(campaign_id: id, created_at: start_date..end_date).sum(:total_price)
  end

  def daily_impressions(start_date: 30.days.ago, end_date: Time.zone.now, board_id: nil)
    if board_id.nil?
      impressions.where(created_at: start_date..end_date).group_by_day(:created_at, format: "%b %d").count
    else
      impressions.where(created_at: start_date..end_date, board_id: board_id).group_by_day(:created_at).count
    end
  end

  def daily_invested( start_date: 30.days.ago, end_date: Time.zone.now, board_id: nil)
    h = impressions.where(campaign_id: id, created_at: start_date..end_date).group_by_day(:created_at, format: "%a").sum(:total_price)
    h.each { |key,value| h[key] = value.round(3) }
  end

  def peak_hours (start_date: 30.days.ago, end_date: Time.zone.now, board_id: nil)
    impressions.where(campaign_id: id, created_at: start_date..end_date).group_by_hour_of_day(:created_at, format: "%l %P").count
  end

  def to_s
    name
  end

  def validate_price_steps
    self.board_campaigns.each do |bc|
      if bc.board.steps
        dist = JSON.parse(budget_distribution)
        budget_board_campaign =  dist["#{bc.board.id}"].to_i
        if !(bc.board.calculate_steps_prices.include? ["$  #{budget_board_campaign} #{ENV.fetch("CURRENCY")}", budget_board_campaign])
          errors.add(:base, I18n.t('campaign.errors.budget_no_valid', name: bc.board.name))
        end
      end
    end
  end

  def test_for_valid_settings(lang: user_locale || ENV.fetch("RAILS_LOCALE"))
    if provider_campaign && state
      boards.each do |b|
        err = b.test_ad_rotation(self, impression_hours.select{|c| !c.marked_for_destruction?}, lang)
        if err.any?
          err.each do |e|
            errors.add(:base, e)
          end
          break
        end
      end
    elsif classification == "per_hour" && state
      boards.each do |b|
        err = b.test_hour_campaigns(self, impression_hours.select{|c| !c.marked_for_destruction?}, lang)
        if err.any?
          err.each do |e|
            errors.add(:base, e)
          end
          break
        end
      end
    end
  end

  def update_bc
    if !self.owner.is_provider?
      board_campaigns.each do |bc|
        bc.update(update_remaining_impressions: true)
      end
    end
  end

  def notify_in_a_week
    bilbo_project_ids = [32] #Projects owned by bilbo
    if ad_id_changed?(from: nil) && self.project.id.in?(bilbo_project_ids)
      SlackNotifyWorker.perform_at(7.days.from_now, "La campaña #{self.name} se creó hace una semana, revisa las metricas!")
    end
  end

  def is_per_hour?
    self.per_hour?
  end

  def is_per_budget?
    self.budget?
  end

  def is_per_minute?
    self.per_minute?
  end

  def create_content
    #create relation ContentsBoardCampaign
    @boards_campaigns_delete = []
    @content = eval(self.content_ids)
    @content.each {|board_slug, content_ids| bc = self.board_campaigns.find_by(board_id: Board.find_by_slug(board_slug).id, campaign: self.id)
      content_ids.split(" ").each {|content| bc.contents_board_campaign.where(content_id: content, boards_campaigns_id: bc.id).first_or_create}
      #delete relation ContentsBoardCampaign
      @boards_campaigns_delete.push(bc.id)
      if bc.contents_board_campaign.where.not(content_id: content_ids.split(" ")).present?
        bc.contents_board_campaign.where.not(content_id: content_ids.split(" ")).each do |x| x.delete end
      end
    }

    BoardsCampaigns.where(campaign_id: self.id).each do |bcb|
      if !bcb.contents_board_campaign.present?
        bcb.destroy
      end
    end

  end

  def contents_present?
    self.content_ids.present?
  end

  def validate_content
    @content = eval(self.content_ids)
    @content.each {|board_slug, content_ids|
      if content_ids == ""
        return errors.add(:base, I18n.t('campaign.errors.no_images'))
      end
    }
  end

  def active_days
    begin
      ((self.ends_at - self.starts_at)/1.days + 1).to_i
    rescue
      #Campaign do not have starts_at or ends_at
      1
    end
  end

  # used for the FRONTEND only
  def duration_in_days
    days = self.active_days
    if active_days == 1
      return "-"
    else
      return days
    end
  end

  def valid_active_time
    if starts_at.nil? or ends_at.nil?
      errors.add(:base, I18n.t('campaign.missing_date'))
    end
  end

  def set_budget(board_campaign)
    if budget_distribution.present?
      dist = JSON.parse(budget_distribution)
      board_campaign.budget = dist[board_campaign.board_id.to_s].to_f
    end
  end

  def update_budget
    if budget_distribution.present?
      total_budget = JSON.parse(budget_distribution).values.map{|x| x.to_f}.sum
      self.budget = total_budget
    end
  end

  # total budget expected to invest
  def expected_investment
    begin
      if starts_at.present? && ends_at.present? && classification == "budget"
        budget * duration_in_days
      else
        "undefined"
      end
    rescue
      0
    end
  end

  def max_impressions(board)
    bc = board_campaigns.find_by(board: board)
    return (bc.budget/(board.get_cycle_price(self, bc)*self.duration/board.duration)).to_i
  end

  def expected_investment
    begin
      if starts_at.present? && ends_at.present? && classification == "budget"
        budget * duration_in_days
      else
        "undefined"
      end
    rescue
      0
    end
  end
end
