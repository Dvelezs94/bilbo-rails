class ImpressionHour < ApplicationRecord
  include ReviewBoardCampaignsConcern
  belongs_to :campaign
  validates_presence_of :start, :end, :imp, :day
  enum day: { monday: 0, tuesday: 1, wednesday: 2, thursday: 3, friday: 4, saturday: 5, sunday: 6, everyday: 7 }
  attr_accessor :owner_updated_campaign
  # before_create :set_in_review_when_create_delete
  # before_destroy :set_in_review_when_create_delete
  # before_update :set_in_review_and_update_price

  def have_to_set_in_review_on_boards
    return start_changed? || end_changed? || imp_changed? || day_changed?
  end

  def set_in_review_when_create_delete
    set_in_review_boards_and_update_price( Campaign.find(self.campaign_id), true, owner_updated_campaign)
  end

  def set_in_review_and_update_price
    set_in_review_boards_and_update_price( Campaign.find(self.campaign_id), have_to_set_in_review_on_boards, owner_updated_campaign)
  end
end
