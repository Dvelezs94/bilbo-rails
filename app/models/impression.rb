class Impression < ApplicationRecord
  include BroadcastConcern
  attribute :api_token

  validate :validate_api_token
  belongs_to :board
  belongs_to :campaign, optional: true
  before_create :set_total_price
  after_create :update_balance
  after_create :continue_runnning_campaign
  private
  def validate_api_token
    if self.board.api_token != api_token
      errors.add(:api_token, "wrong")
    end
  end

  def set_total_price
    if self.campaign.provider_campaign
      self.total_price = 0
    else
      self.total_price = (board.cycle_price * cycles).round(3)
    end
  end

  def update_balance
    self.campaign.project.owner.charge!(self.total_price)
  end

  def continue_runnning_campaign
    if self.campaign.should_run?
      true
    else
      remove_campaign(self.campaign.id, self.board.id)
    end
  end
end
