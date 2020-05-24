class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, presence: true, exclusion: { in: %w(www app admin),
    message: "%{value} is reserved." }

  enum status: { enabled: 0, disabled: 1 }

  has_many :project_users
  has_many :users, through: :project_users
  has_many :campaigns
  has_many :ads
  has_many :boards
  has_many :reports
  # the project has notifications so all users in the project can see them
  has_many :notifications, foreign_key: :recipient_id

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

  def users
    project_users.pluck(:user_id)
  end

  def owned?(user_id)
    [owner.id].include? user_id
  end

  def admin?(user_id)
    admins.include? user_id || owned?(user_id)
  end

  # !!methods for statistics

  # gives an array with the user boards and the respective impressions in a given time
  # sample output: [{"board_name": "V.carranza", "impressions": 435}, {"board_name": "E.zapata", "impressions": 544}]
  def impressions_by_boards(start = 4.weeks.ago)
    total_impressions = Impression.where(board_id: boards.pluck(:id), created_at: start.beginning_of_day..DateTime.now)
    total_impressions = total_impressions.group_by_day(:created_at).count
    total_impressions
  end

  # return a COUNT impressions for campaigns
  # call it like -
  # current_user.daily_provider_board_impressions(6.months.ago).group_by_day(:created_at).count
  def daily_provider_board_impressions(time_range = 30.days.ago..Time.now)
    Impression.joins(:board).where(boards: {project_id: id}, created_at: time_range)
  end

  # campaigns that require provider feedback to be aither approved or denied
  def campaigns_for_review
    BoardsCampaigns.in_review.where(board: [boards]).size
  end

  def active_campaigns
    BoardsCampaigns.approved.where(board: [boards]).size
  end
end
