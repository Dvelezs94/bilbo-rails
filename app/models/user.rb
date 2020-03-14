class User < ApplicationRecord
  attribute :project_name
  ############################################################################################
  ## PeterGate Roles                                                                        ##
  ## The :user role is added by default and shouldn't be included in this list.             ##
  ## The :root_admin can access any page regardless of access settings. Use with caution!   ##
  ## The multiple option can be set to true if you need users to have multiple roles.       ##
  petergate(roles: [:admin, :provider], multiple: false)                                      ##
  ############################################################################################


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :confirmable, :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  validates :email, presence: true, format: Devise.email_regexp
  has_many :boards
  # project related methods
  has_many :project_users
  has_many :projects, through: :project_users
  after_commit :set_project, on: :create

  has_many :payments
  has_many :invoices
  has_one_attached :avatar
  attr_readonly :email

  # returns a hash of total prints per day, WITHOUT grouping the boards
  # def total_board_impressions(start = 4.weeks.ago)
  #   total_impressions = Impression.where(board_id: boards.pluck(:id), created_at: start.beginning_of_day..DateTime.now)
  #   total_impressions = total_impressions.group_by_day(:created_at).count
  #   total_impressions
  # end

  def month_board_impressions(start = DateTime.now)
    total_impressions = Impression.where(board_id: boards.pluck(:id), created_at: start.beginning_of_month..start.end_of_month)
    total_impressions.sum(:cycles) * board.cycle_price
  end

  # get current month impressions * impression price
  def current_month_earnings
  end

  # provider methods


  # return a COUNT impressions for campaigns
  # call it like -
  # current_user.daily_provider_board_impressions(6.months.ago).group_by_day(:created_at).count
  def daily_provider_board_impressions(time_range = 30.days.ago..Time.now)
    Impression.joins(:board).where(boards: {user_id: id}, created_at: time_range)
  end

  def projects_owned
    project_users.where(role: "owner")
  end

  def name_or_email
    name || email
  end

  private

  def set_project
    @project = Project.new(name: project_name)
    @project.project_users.new(user: self, role: "owner")
    @project.save
  end
end
