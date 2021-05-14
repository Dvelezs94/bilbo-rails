class Impression < ApplicationRecord
  include BroadcastConcern
  attribute :api_token
  attr_accessor :action
  validate :validate_api_token
  # validates_uniqueness_of :created_at, scope: [:board_id, :campaign_id]
  #validate :ten_seconds_validate_board_campaign
  belongs_to :board
  belongs_to :campaign
  before_create :set_prices
  after_create :update_campaign_fields
  after_save :update_balance_and_remaining_impressions
  after_commit :continue_running_campaign

  def action #is used to make the action in board
    @action  || "delete" #default action is delete in front, if specified then keep
  end
  
  private
  def update_balance_and_remaining_impressions
    begin
      self.campaign.project.owner.charge!(amount: self.total_price)
      if self.campaign.classification == "budget" || self.campaign.classification == "per_hour"
        BoardsCampaigns.find_by(board: self.board, campaign: self.campaign).decrement!(:remaining_impressions)
      end
    rescue
      Bugsnag.notify("Posiblemente se cobro por esta impresion de #{self.total_price} en el bilbo #{self.board.name}")
    end
  end

  # update all campaign fields in a single method
  def update_campaign_fields
    increase_count = (self.board.people_per_second * self.campaign.true_duration(self.board_id)).round(0)
    self.campaign.increment!(:people_reached, by = increase_count)
    self.campaign.increment!(:impression_count)
    self.campaign.increment!(:total_invested, by = self.total_price)
  end

  def validate_api_token
    if self.board.api_token != api_token
      errors.add(:api_token, "wrong")
    end
  end

  def set_prices
    if self.campaign.provider_campaign
      self.total_price = 0
      self.provider_price = 0
    else
      self.total_price = (board.get_cycle_price(campaign) * cycles).round(3)
      self.provider_price = (board.provider_cycle_price * cycles).round(3)
    end
  end

  def continue_running_campaign
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

  def increase_campaign_impression_count
    self.campaign.with_lock do
      self.campaign.increment!(:impression_count)
    end
  end
end
