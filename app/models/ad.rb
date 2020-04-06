class Ad < ApplicationRecord
  #attr accessor is for trigger the changes on the multimedia
  attr_accessor :multimedia_update
  extend FriendlyId

  friendly_id :name, use: :slugged

  belongs_to :project

  has_many :campaigns
  has_many_attached :multimedia
  enum status: { active: 0, deleted: 1 }

  validates :name, presence: true

  validates :multimedia, content_type: ["image/png", "image/jpeg", "image/gif"]
  #this is executed when user is trying to delete the ad
  validate :check_if_can_delete, if: :status_changed_to_deleted?
  #this is executed when the ad update the multimedia
  before_commit :change_status

  def check_if_can_delete
    if self.campaigns.select_active.size > 0
      errors.add(:base, I18n.t('ads.errors.wont_be_able_to_delete'))
    end
  end

  def status_changed_to_deleted?
    status_changed?(to: "deleted")
  end

 #this method changes the status of campaigns approved to in review
  def change_status
    if multimedia_update
      BoardsCampaigns.approved.where(campaign: campaigns.active).update_all(status: "in_review")
    end
   end
end
