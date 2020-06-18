class UserActivity < ApplicationRecord
  belongs_to :user
  belongs_to :activeness, polymorphic: true
end
