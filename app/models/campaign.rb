class Campaign < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include BroadcastConcern
  extend FriendlyId
  attr_accessor :provider_update
  friendly_id :name, use: :slugged
  belongs_to :project
  has_many :impressions
  has_many :campaign_denials
  belongs_to :ad, optional: true
  has_many :board_campaigns, class_name: "BoardsCampaigns"
  has_many :boards, through: :board_campaigns
  has_many :provider_invoices
  # status is for the
  enum status: { active: 0, inactive: 1 }
  enum clasification: {budget: 0, per_minute: 1, per_hour: 2}

  # 'state' is for user desired state ser by the user, enabled or disabled

  # Trigger broadcast or remove campaign
  before_destroy :remove_campaign

  validates :name, presence: true
  # validates :ad, presence: true, on: :update
  validate :state_change_time, on: :update,  if: :state_changed?
  validate :cant_update_when_active, on: :update
  validate :test_for_valid_settings
  validate :check_build_ad_rotation, if: :provider_campaign
  validate :validate_ad_stuff, on: :update
  after_validation :return_to_old_state_id_invalid
  before_save :update_state_updated_at, if: :state_changed?
  after_commit :update_rotation_on_boards
  before_save :set_in_review



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

  def set_in_review
    self.board_campaigns.update_all(status: "in_review") if ad_id_changed? || provider_update
  end

  # distribute budget evenly between all bilbos
  def budget_per_bilbo
    self.budget / boards.length
  end
  def check_build_ad_rotation
    if (state)
      boards.each do |b|
        err = b.build_ad_rotation(self) if !provider_update
        if err.present?
          errors.add(:base, err.first)
          break
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
      if clasification == "budget" && self.budget >= 50 && !campaign_budget_spent? && ( provider_campaign || project.owner.balance >= 5 )
        return true
      elsif clasification == "per_minute"
        return true
      elsif clasification == "per_hour"
        return true
      end
    end
    return false
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
    time - utc_offset
  end

  def time_to_run?(brd)
    # if set start and end to august 4, it runs all august 4 day
    # if set from 4 aug to 5 aug, it runs entire both days
    #utc is used to compare dates correctly
    (self.starts_at.nil? && self.ends_at.nil?) || (to_utc(self.starts_at,brd.utc_offset).to_date <= Time.now.utc.to_date && to_utc(self.ends_at,brd.utc_offset).to_date  >= Time.now.utc.to_date)
  end


  def update_rotation_on_boards
    boards.each do |b|
      if provider_campaign && campaign_active_in_board?(b.id)#needs to update provider campaigns
        err = b.update_ads_rotation(self)
      elsif campaign_active_in_board?(b.id) #if user, worker adds the campaign in real time
        b.update_campaign_broadcast(self)
      end
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
    minutes_needed = (ENV["RAILS_ENV"] == "development")? 0.1.minutes : 0.2.minutes
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

  def cant_update_when_active
    if self.state_was && !state_changed?
      #this can happen when someone is passing campaign to false and also updating other attributes, but i dont think now that will cause problems
      #something is changing when state is active, so i raise error
      errors.add(:base, I18n.t('campaign.errors.cant_update_when_active'))
    end
  end

  # Get total ammount of money invested on the campaign to date
  def total_invested
    Impression.where(campaign_id: id).sum(:total_price)
  end

  def daily_impressions(time_range = 30.days.ago..Time.now )
    impressions.where(campaign_id: id,created_at: time_range).group_by_day(:created_at).count
  end

  def daily_invested( time_range = 30.days.ago..Time.now)
    h = impressions.where(campaign_id: id, created_at: time_range).group_by_day(:created_at, format: "%a").sum(:total_price)
    h.each { |key,value| h[key] = value.round(3) }
  end

  def peak_hours (time_range = 30.days.ago..Time.now)
    impressions.where(campaign_id: id, created_at: time_range).group_by_hour_of_day(:created_at, format: "%l %P").count
  end

  def to_s
    name
  end

  def test_for_valid_settings
    if provider_campaign && state
      boards.each do |b|
        err = b.test_ad_rotation(self)
        if err.any?
          err.each do |e|
            errors.add(:base, e)
          end
          break
        end
      end
    end
  end

end
