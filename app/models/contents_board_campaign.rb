class ContentsBoardCampaign < ApplicationRecord
  belongs_to :content
  belongs_to :boards_campaigns

  after_create :set_board_campaigns_to_review
  before_destroy :set_board_campaigns_to_review

  private

  def set_board_campaigns_to_review
    self.boards_campaigns.update_column(:status, BoardsCampaigns.statuses[:in_review])
  end
end
