class ContentsBoardCampaign < ApplicationRecord
  belongs_to :content
  belongs_to :boards_campaigns
end
