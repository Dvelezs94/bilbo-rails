class ProjectUser < ApplicationRecord
  attribute :email, :string

  belongs_to :project
  belongs_to :user

  enum role: { owner: 0, administrator: 1, user: 2 }

  before_validation :set_user_id, if: :email?
  validates_uniqueness_of :project_id, :scope => :user_id, :message => "Duplicate"
  validate :user_invited_provider?
  
  def set_user_id
    self.user = User.invite!(email: email, project_name: email)
  end

  def user_invited_provider?
    if self.user.is_provider?
      return errors.add :base, "Can't invite providers users"
    end
  end
end
