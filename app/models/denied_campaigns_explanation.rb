class DeniedCampaignsExplanation < ApplicationRecord
  belongs_to :boards_campaigns
  enum message: { inappropriate_content: 0, too_long_short: 1, budget_very_low: 2, message_not_appropiate: 3, resolution_very_low: 4, choosen_dates_not_aviable: 5 }
end
