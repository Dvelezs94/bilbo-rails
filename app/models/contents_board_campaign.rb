class ContentsBoardCampaign < ApplicationRecord
  belongs_to :content
  belongs_to :boards_campaigns

  attr_accessor :skip_some_callbacks
  after_create :set_board_campaigns_to_review, unless: :skip_some_callbacks
  before_destroy :set_board_campaigns_to_review, unless: :skip_some_callbacks
  private

  def set_board_campaigns_to_review
    self.boards_campaigns.update_column(:status, BoardsCampaigns.statuses[:in_review])
  end
end
