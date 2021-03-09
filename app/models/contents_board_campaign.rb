class ContentsBoardCampaign < ApplicationRecord
  belongs_to :content
  belongs_to :board_campaigns
end
