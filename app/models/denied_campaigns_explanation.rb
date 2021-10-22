class DeniedCampaignsExplanation < ApplicationRecord
  belongs_to :boards_campaigns
  MESSAGES=[ I18n.t("denied.inappropriate_content"), I18n.t("denied.too_long_short"), I18n.t("denied.budget_very_low"), I18n.t("denied.message_not_appropiate"), I18n.t("denied.resolution_very_low"), I18n.t("denied.choosen_dates_not_aviable") ]
end
