class BoardsCampaigns < ApplicationRecord
    belongs_to :campaign
    belongs_to :board

    enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3 }
end