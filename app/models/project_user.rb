class ProjectUser < ApplicationRecord
  attribute :email, :string

  belongs_to :project
  belongs_to :user

  enum role: { owner: 0, administrator: 1, user: 2 }

  before_validation :set_user_id, if: :email?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def set_user_id
    self.user = User.invite!(email: email, project_name: email.split("@")[0])
  end
end
