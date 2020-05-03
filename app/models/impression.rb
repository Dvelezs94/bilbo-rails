class Impression < ApplicationRecord
  attribute :api_token

  validate :validate_api_token
  belongs_to :board
  belongs_to :campaign, optional: true
  before_create :set_total_price
  after_create :update_balance

  private
  def validate_api_token
    if self.board.api_token != api_token
      errors.add(:api_token, "wrong")
    end
  end

  def set_total_price
    self.total_price = (board.cycle_price * cycles).round(3)
  end

  def update_balance
    self.campaign.project.owner.charge!(self.total_price)
  end
end
