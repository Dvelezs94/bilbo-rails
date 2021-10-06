class DeniedCampaignsExplanation < ApplicationRecord
  belongs_to :boards_campaigns
  enum message: { ilegal: 0, restricted_ad: 1, unpermitted: 2 }
end
