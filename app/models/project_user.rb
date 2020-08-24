class ProjectUser < ApplicationRecord
  attribute :email, :string

  belongs_to :project
  belongs_to :user

  enum role: { owner: 0, administrator: 1, user: 2 }

  before_validation :set_user_id, if: :email?
  validates_uniqueness_of :project_id, :scope => :user_id, :message => "Duplicate"

  def set_user_id
    if User.find_by(email: email).present? && User.find_by(email: email).is_provider? && User.find_by(email: email).projects.present?
        return errors.add :base, "Can't invite providers users"
    else
      self.user = User.invite!(email: email, project_name: email)
    end
  end
end
