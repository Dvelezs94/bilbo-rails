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
    self.campaigns.each do |campaign|
      if campaign.state
        errors.add(:base, I18n.t('ads.wont_be_able_to_delete'))
        break
      end
    end
  end

  def status_changed_to_deleted?
    status_changed?(to: "deleted")
  end
end
