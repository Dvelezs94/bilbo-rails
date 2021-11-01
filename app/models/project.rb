class Project < ApplicationRecord
  extend FriendlyId
  include DatesHelper
  friendly_id :name, use: :slugged

  validates :name, presence: true, exclusion: { in: %w(www app admin),
    message: "%{value} is reserved." }

  enum status: { enabled: 0, disabled: 1 }
  enum classification: { user: 0, provider: 1, admin: 2 }

  has_many :project_users
  has_many :users, through: :project_users
  has_many :campaigns
  has_many :boards
  has_many :reports
  has_many :contents
  has_one :dashboard_player
  # the project has notifications so all users in the project can see them
  has_many :notifications, foreign_key: :recipient_id
  after_commit :disable_campaigns!, on: :update

  # useful when you want to retrieve a collection of certain users that have permissions for the project
  # current_user.projects.admins -> will get the admins of all the projects
  scope :owners, -> { joins(:project_users).where(project_users: {role: ['owner']}).pluck(:user_id) }
  scope :admins, -> { joins(:project_users).where(project_users: {role: ["owner", "administrator"]}).pluck(:user_id) }
  scope :users, -> { joins(:project_users).pluck(:user_id) }

  # functions to get the users of a specific project
  # Project.first.owner
  def owner
    project_users.find_by_role("owner").user
  end

  def admins
    project_users.where(role: ["owner", "administrator"]).pluck(:user_id)
  end

  def project_enabled?
   if self.enabled?
    true
   else
    false
   end
  end

  def disable_campaigns!
    if self.disabled?
      self.campaigns.update_all(state: false)
    end
  end
  #
  # def users
  #   project_users.pluck(:user_id)
  # end

  def owned?(user_id)
    [owner.id].include? user_id
  end

  def admin?(user_id)
    admins.include? user_id || owned?(user_id)
  end

  # !!methods for statistics

  # gives an array with the user boards and the respective impressions in a given time
  # sample output: [{"board_name": "V.carranza", "impressions": 435}, {"board_name": "E.zapata", "impressions": 544}]
  def impressions_by_boards(start: 1.month.ago)
    get_month_cycle(date: start)
    total_impressions = Impression.where(board_id: boards.pluck(:id), created_at: @start_date..@end_date)
    total_impressions = total_impressions.group_by_day(:created_at).count
    total_impressions
  end

  def campaigns_count(start: 1.month.ago)
    get_month_cycle(date: start)
    Impression.where(board_id: boards.pluck(:id), created_at: @start_date..@end_date).pluck(:campaign_id).uniq.count
  end

  # return a COUNT impressions for campaigns on top 10 bilbos
  def top_provider_board_impressions(time_range = 30.days.ago..Time.now)
    zeros = (time_range.first.to_date .. time_range.last.to_date-1.day).map{|d| [(I18n.l d, format: "%b %d"), 0]}.to_h
    self.boards.sort_by{|board| -board.impressions.where(created_at: time_range).sum(:provider_price)}.first(10).map{|board| {name: board.name, data: zeros.merge(board.impressions.where(created_at: time_range).group_by_day(:created_at, format: "%b %d").count)}}
  end

  def daily_provider_board_impressions(time_range = 30.days.ago..Time.now)
    Impression.joins(:board).where(boards: {project_id: id}, created_at: time_range)
  end

  def boards_count
    boards.size
  end

  # campaigns that require provider feedback to be aither approved or denied
  def campaigns_for_review
    Campaign.active.where("ends_at >= ?", Date.today).joins(:boards).merge(self.boards).pluck(:id).each do |c|
      @campaign_loop = Campaign.find(c)
      # to be optimized
      if @campaign_loop.owner.has_had_credits? || @campaign_loop.provider_campaign?
        @camp = Array(@camp).push(c)
      end
    end
    BoardsCampaigns.where(board: self.boards.enabled.pluck(:id), campaign: @camp).in_review.count
  end

  def provider_project?
    self.classification == "provider"
  end

  def active_campaigns
    BoardsCampaigns.where(board: self.boards.enabled.pluck(:id), campaign: Campaign.active.where("ends_at >= ?", Date.today).joins(:boards).merge(self.boards).pluck(:id)).approved.count
  end
end
