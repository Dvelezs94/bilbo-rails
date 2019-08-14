class Campaign < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user
  has_many :prints
  belongs_to :ad, optional: true
  has_many :orders
  has_and_belongs_to_many :boards
  enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3}
  validates :name, presence: true
  before_save :set_in_review, :if => :ad_id_changed?

  def total_invested
    self.orders.sum(:total)
  end

  def ongoing?
    # validates if both fields are complete
    !(self.starts_at? && self.ends_at?)
  end

  def set_in_review
    self.status = "in_review"
  end
end
