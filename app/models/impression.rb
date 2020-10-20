class Impression < ApplicationRecord
  include BroadcastConcern
  attribute :api_token
  attr_accessor :action
  validate :validate_api_token
  validates_uniqueness_of :created_at, scope: [:board_id, :campaign_id]
  #validate :ten_seconds_validate_board_campaign
  belongs_to :board
  belongs_to :campaign
  before_create :set_total_price
  after_create :update_balance
  after_create :continue_runnning_campaign
  def action #is used to make the action in board
    @action  || "delete" #default action is delete in front, if specified then keep
  end
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
      self.total_price = (board.get_cycle_price(campaign) * cycles).round(3)
    end
  end

  def update_balance
      self.campaign.project.owner.charge!(self.total_price)
  end

  def continue_runnning_campaign
    if self.campaign.should_run?(board_id)
      true
    else
      remove_campaign(self.campaign.id, self.board.id)
    end
  end

  def ten_seconds_validate_board_campaign
    #this method obtains the last impression made on the board with the campaign to validate the rank is not less than ten seconds
    if (self.campaign.present?) && (self.board.present?)
      impression = Impression.order(created_at: :desc).find_by(board_id: self.board.id, campaign_id: self.campaign.id)
      if impression.present?
        if ((self.created_at - impression.created_at).abs.round < 10)
          return errors.add :base, "Impression duplicate in less ten seconds"
        end
      end
    end
  end
end
