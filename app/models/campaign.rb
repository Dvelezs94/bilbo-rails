class Campaign < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper
  include BroadcastConcern
  include ShortenerHelper
  include ProjectConcern
  include ReviewBoardCampaignsConcern
  extend FriendlyId
  attr_accessor :owner_updated_campaign
  friendly_id :slug_candidates, use: :slugged
  belongs_to :project
  has_many :impressions
  has_many :campaign_denials
  has_many :impression_hours
  accepts_nested_attributes_for :impression_hours, reject_if: :all_blank, allow_destroy: true
  belongs_to :ad, optional: true
  has_many :board_campaigns, class_name: "BoardsCampaigns"
  has_many :boards, through: :board_campaigns
  has_many :provider_invoices

  amoeba do
    enable
    include_association :impression_hours, if: :is_per_hour?
    #include_association :boards, through: :board_campaigns
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
  enum clasification: {budget: 0, per_minute: 1, per_hour: 2}

  # 'state' is for user desired state ser by the user, enabled or disabled

  # Trigger broadcast or remove campaign
  before_destroy :remove_campaign

  validates :name, presence: true
  validates :provider_campaign, inclusion: [true, false]
  #validates :ad, presence: true, on: :update
  validate :project_enabled?
  validate :state_change_time, on: :update,  if: :state_changed?
  validate :check_user_verified, on: :update,  if: :state_changed?
  validate :cant_update_when_active, on: :update
  validate :validate_ad_stuff, on: :update
  validate :ad_processed, on: :update
  validate :test_for_valid_settings
  validate :check_build_ad_rotation, if: :provider_campaign
  after_validation :return_to_old_state_id_invalid
  validate :budget_validation, if: :is_per_budget?
  before_save :update_state_updated_at, if: :state_changed?
  before_save :notify_in_a_week, if: :ad_id_changed?
  before_update :set_in_review_and_update_price
  after_commit :broadcast_to_all_boards
  after_update :update_bc
  after_update :generate_shorten_url

  def owner
    self.project.owner
  end

  def generate_shorten_url
    shorten_link(analytics_campaign_url(slug))
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
  def budget_per_bilbo
    self.budget / boards.length
  end

  def check_build_ad_rotation
    if ( state && state_changed? && !have_to_set_in_review_on_boards )
      boards.each do |b|
        if self.should_run?(b.id) && b.get_campaigns
          #Check the ad rotation with the total impressions (for budget campaigns) but do not save
          err = b.build_ad_rotation(self,true)
          if err.present?
            errors.add(:base, err.first)
            break
          end
          #In case no error is found
          #Build again the ad rotation and save it, only with the remaining impressions of the budget campaigns
          err2 = b.build_ad_rotation
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
    if self.status == "active" && self.state && campaign_active_in_board?(board_id) && time_to_run?(brd)
      if clasification == "budget" && self.budget >= 50 && !campaign_budget_spent? && ( self.remaining_impressions(board_id) > 0 && (provider_campaign || project.owner.balance >= 5))
        return true
      elsif clasification == "per_minute"
        return true
      elsif clasification == "per_hour" && self.remaining_impressions(board_id) > 0 && (provider_campaign || project.owner.balance >= 5)
        return true
      end
    end
    return false
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
    time - utc_offset.minutes
  end

  def time_to_run?(brd)
    # if set start and end to august 4, it runs all august 4 day
    # if set from 4 aug to 5 aug, it runs entire both days
    #utc is used to compare dates correctly
    (self.starts_at.nil? && self.ends_at.nil?) || (to_utc(self.starts_at,brd.utc_offset).to_date <= Time.now.utc.to_date && to_utc(self.ends_at,brd.utc_offset).to_date  >= Time.now.utc.to_date)
  end


  def broadcast_to_all_boards
    boards.each do |b|
      err = b.broadcast_to_board(self)
      #currently no use for errors here
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

  def state_change_time
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
    errors.add(:base, "#{I18n.t ('campaign.wont_be_able_to_update_state')} #{distance_of_time_in_words( (minutes_needed - time_elapsed).ago, Time.now, include_seconds: true )}") if (time_elapsed < minutes_needed)
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

  # Get total ammount of money invested on the campaign to date
  def total_invested(start_date: 30.days.ago, end_date: Time.zone.now, board_id: nil)
    Impression.where(campaign_id: id, created_at: start_date..end_date).sum(:total_price)
  end

  def daily_impressions(start_date: 30.days.ago, end_date: Time.zone.now, board_id: nil)
    if board_id.nil?
      impressions.where(created_at: start_date..end_date).group_by_day(:created_at).count
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

  def test_for_valid_settings
    if provider_campaign && state
      boards.each do |b|
        err = b.test_ad_rotation(self, impression_hours.select{|c| !c.marked_for_destruction?})
        if err.any?
          err.each do |e|
            errors.add(:base, e)
          end
          break
        end
      end
    elsif clasification == "per_hour" && state
      boards.each do |b|
        err = b.test_hour_campaigns(self, impression_hours.select{|c| !c.marked_for_destruction?})
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

  def budget_validation
    if budget.present?
      if budget_per_bilbo < 50
        errors.add(:base, I18n.t('campaign.minimum_budget_per_bilbo'))
      end
    end
  end



end
