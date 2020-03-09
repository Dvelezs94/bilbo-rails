class User < ApplicationRecord
  ############################################################################################
  ## PeterGate Roles                                                                        ##
  ## The :user role is added by default and shouldn't be included in this list.             ##
  ## The :root_admin can access any page regardless of access settings. Use with caution!   ##
  ## The multiple option can be set to true if you need users to have multiple roles.       ##
  petergate(roles: [:admin, :provider], multiple: false)                                      ##
  ############################################################################################


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]
  has_many :boards
  has_many :campaigns
  has_many :payments
  has_many :invoices
  has_one_attached :avatar
  attr_readonly :email
  has_many :ads

  # gives an array with the user boards and the respective impressions in a given time
  # sample output: [{"board_name": "V.carranza", "impressions": 435}, {"board_name": "E.zapata", "impressions": 544}]
  def impressions_by_boards(start = 4.weeks.ago)
    total_impressions = Impression.where(board_id: boards.pluck(:id), created_at: start.beginning_of_day..DateTime.now)
    #total_impressions = total_impressions.select(:created_at, :board_id)
    # Impression.where(board_id: User.find(39).boards.pluck(:id), created_at: 4.weeks.ago.beginning_of_day..DateTime.now)
    # total_impressions = total_impressions.group_by{ |t| [created_at.beginning_of_day, t.board_id] }
    total_impressions = total_impressions.group_by_day(:created_at).count
    total_impressions
  end

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

  def display_method
    "#{self.email}.camelize"
    
  # provider methods

  # campaigns that require provider feedback to be aither approved or denied
  def campaigns_for_review
    Campaign.in_review.joins(:boards).where(boards: {user_id: id}).length
  end

  def active_campaigns
    Campaign.approved.joins(:boards).where(boards: {user_id: id}).length
  end

  # return a COUNT impressions for campaigns
  # call it like -
  # current_user.daily_provider_board_impressions(6.months.ago).group_by_day(:created_at).count
  def daily_provider_board_impressions(time_range = 30.days.ago..Time.now)
    Impression.joins(:board).where(boards: {user_id: id}, created_at: time_range)

  end
end
