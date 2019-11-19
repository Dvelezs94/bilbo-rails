class Ad < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user

  has_many :campaigns
  has_many_attached :multimedia

  enum status: { active: 0, deleted: 1 }

  validates :name, presence: true

  validates :multimedia, content_type: ["image/png", "image/jpeg", "image/gif"]
  #this is executed when user is trying to delete the ad
  validate :check_if_can_delete, :if => :status_changed_to_deleted?


  def check_if_can_delete
    if self.campaigns.select_active.length > 0
      errors.add(:base, I18n.t('ads.errors.wont_be_able_to_delete'))
    end
  end

  def status_changed_to_deleted?
    status_changed?(to: "deleted")
  end
end
