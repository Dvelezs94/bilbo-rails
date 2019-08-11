class Campaign < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user
  has_many :prints
  belongs_to :ad, optional: true
  has_many :orders
  has_and_belongs_to_many :boards
  enum status: { in_review: 0, approved: 1, denied: 0}
  validates :name, presence: true

  def total_invested
    self.orders.sum(:total)
  end

  def ongoing?
    # validates if both fields are complete
    !(self.starts_at? && self.ends_at?)
  end
end
