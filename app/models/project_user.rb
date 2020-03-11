class ProjectUser < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum role: { owner: 0, maintainer: 1, user: 2 }
end
