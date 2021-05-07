class User < ApplicationRecord
  attribute :project_name
  include NotificationsHelper
  include BroadcastConcern
  include DatesHelper
  include NumbersHelper
  include SendgridHelper
  include Rails.application.routes.url_helpers
  ############################################################################################
  ## PeterGate Roles                                                                        ##
  ## The :user role is added by default and shouldn't be included in this list.             ##
  ## The :root_admin can access any page regardless of access settings. Use with caution!   ##
  ## The multiple option can be set to true if you need users to have multiple roles.       ##
  petergate(roles: [:admin, :provider], multiple: false)                                      ##
  ############################################################################################


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  validates :email, presence: true, format: Devise.email_regexp
  validates :name, format: { :with => /\A[^0-9`!@#\$%\^&*+_=]+\z/, multiline: false, message: 'Invalid name' }
  validates_with PhoneValidator
  #validates_format_of :phone_number, with: /\A\+\d{1,3}\d{10}\z/i, allow_nil: true, message: I18n.t("validations.only_numbers_for_phone")
  has_many :boards
  # project related methods
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
  after_commit :set_project, on: :create
  after_create :send_contact_sendgrid
  before_save :send_contact_sendgrid, if: :name_changed?
  before_save :notify_credits, if: :balance_changed?
  has_many :payments
  has_many :invoices
  has_many :provider_invoices
  has_many :reports
  has_many :notifications, through: :projects
  has_one_attached :avatar
  attr_readonly :email
  has_many :verifications
  scope :providers, -> { where("roles like ?", "%provider%") }

  # omniauth functions
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.project_name = auth.info.name
    end
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
  def current_month_earnings(time_range = 30.days.ago..Time.now)
    Board.last.monthly_earnings(time_range)
  end

  # make sure to log in if user is not banned
  def active_for_authentication?
    super and !self.banned?
  end

  # provider methods


  # return a COUNT impressions for campaigns
  # call it like -
  # current_user.daily_provider_board_impressions(6.months.ago).group_by_day(:created_at).count
  def daily_provider_board_impressions(time_range = 30.days.ago..Time.now)
    Impression.joins(:board).where(boards: {user_id: id}, created_at: time_range)
  end

  def locale
    super.nil?? ENV.fetch("RAILS_LOCALE").to_sym : super.to_sym
  end

  def name_or_email
    begin
      name.split.first
    rescue
      email
    end
  end

  def name_or_none
    begin
      name.split.first
    rescue
      ""
    end
  end

  def is_admin?
    role == :admin
  end

  def is_provider?
   role == :provider
  end

  def is_user?
    role == :user
  end

  # get enabled projects that the user owns
  def owned_projects
    Project.joins(:project_users).where(["project_users.user_id = ? AND role = ?", self.id, 0])
  end

  def owner_project
    self.project_users.where(role: "owner")
  end

  def toggle_ban!
    if self.banned?
      update_attribute :banned, false
      @status = "enabled"
    else
      update_attribute :banned, true
      @status = "disabled"
    end
    @project_ids = ProjectUser.where(user_id: id, role: "owner").pluck(:project_id)
    self.projects.where(id: [@project_ids]).update(status: @status)
  end

  def add_credits(total)
    if self.is_user? && (total.to_i >= 50)
      self.increment!(:balance, by = total.to_i)
      SlackNotifyWorker.perform_async("El usuario #{self.email} ha comprado #{total.to_i} créditos")
      I18n.locale = locale
      NotificationMailer.new_notification(user: self, message: I18n.t("notifications.credits.assigned.message", credits: total.to_i),
        subject: I18n.t("notifications.credits.assigned.subject", credits: total.to_i)).deliver
      return true
    else
      self.errors.add(:base, "You have to purchase 50 or more credits")
      false
    end
  end



  def notify_credits
    if self.balance < 5 && self.is_user?.present?
      self.projects.each do |project|
        #the project have active campaigns, if the project dont have notifications created or check if created at 30 minutes
        if project.campaigns.find_by(state: true).present?
          if project.notifications.find_by(action: "out of credits").nil? || project.notifications.find_by(action: "out of credits").created_at < Time.zone.now.ago(30.minutes)
            create_notification(recipient_id: project.id, actor_id: project.id, action: "out of credits", notifiable: self)
            break
          end
        end
      end
    end
  end

  def charge!(amount: 0, camp_id: nil)
    begin
      self.with_lock do
        self.update_column(:balance, self.balance -= amount.to_f)
      end
      # Increase total invested on campaign
      if camp_id.is_a? Integer
        camp = Campaign.find(camp_id)
        camp.with_lock do
          camp.update_column(:total_invested, camp.total_invested += amount.to_f)
        end
      end
    rescue => e
      ## make sure we send an alert if the impressions fail to create
      Bugsnag.notify(e)
    end
  end

  # sends the html content (images) when the user buys credits
  def resume_campaigns
    camp_ids = []
    projects.select {|pr| pr.admin?(self.id) }.each do |p|
      camp_ids << p.campaigns.pluck(:id)
    end
    bc = BoardsCampaigns.where(status: "approved", campaign_id: camp_ids)

    bc.each do |obj|
      brd = obj.board
      camp = obj.campaign
      err = brd.broadcast_to_board(camp, true)
    end
  end

  # month: Report of the month you want to send to the provider
  # method: :print/:email print results or email results
  def send_provider_report(date: Time.zone.now, method: :print)
    return "This method is only for providers" if !self.is_provider?
    # current month
    get_month_cycle(date: date)
    @project = self.projects.first
    @gross_earnings = Board.provider_monthly_earnings_by_board(@project, @start_date..@end_date)
    @net_earnings = (@gross_earnings).round(2)

    # previous month
    get_month_cycle(date: date - 1.month)
    @gross_earnings_previous = Board.provider_monthly_earnings_by_board(@project, @start_date..@end_date)
    @earnings_percentage = get_percentage(@gross_earnings_previous, @gross_earnings)
    if @earnings_percentage.positive?
      @earnings_percentage = I18n.t('campaign.percentage_plus', percentage: @earnings_percentage)
    else
      @earnings_percentage =  I18n.t('campaign.percentage_minus', percentage: @earnings_percentage)
    end
    report = Hash.new
    report[:month] = I18n.t('date.month_names')[date.month]
    report[:earnings_percentage_comparison] = @earnings_percentage
    report[:net_earnings] = @net_earnings
    report[:campaigns_count] = @project.campaigns_count
    report[:link] = provider_statistics_dashboards_url("select[month]": date.month, "select[year]": date.year)
    if method == :print
      return report
    elsif method == :email
      UserMailer.monthly_provider_report(self, report[:month], report[:net_earnings], report[:campaigns_count], report[:earnings_percentage_comparison], report[:link]).deliver
    else
      return "Specify :email or :print for 'method' attribute"
    end
  end

  # check if user has either purchased or had credits somehow
  def has_had_credits?
    if self.balance != 0 || !payments.empty?
      true
    else
      false
    end
  end

  def first_name
    begin
      name.split.first
    rescue
      ""
    end
  end

  def last_name
    begin
      name.split(' ')[1..].join(" ")
    rescue
      ""
    end
  end

  private

  def set_project
    @project = Project.new(name: project_name, classification: self.role.to_s)
    @project.project_users.new(user: self, role: "owner")
    @project.available_campaign_types = ["budget","per_minute","per_hour"].to_s if self.is_provider?
    @project.save
  end

  def send_contact_sendgrid
    #create a contact in lists of sengrid
    sync_sendgrid_user(self)
  end

end
