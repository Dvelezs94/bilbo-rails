class Witness < ApplicationRecord
  include NotificationsHelper
  extend FriendlyId
  friendly_id :friendly_uuid, use: :slugged
  belongs_to :campaign
  has_many :evidences
  enum status: { pending: 0, ready: 1 }
  after_create :create_notification_evidence
  accepts_nested_attributes_for :evidences

  def friendly_uuid
      SecureRandom.uuid
    end

  def create_notification_evidence
    self.campaign.board_campaigns.approved.each do |bc|
      board = bc.board_id
      self.evidences.create(board_id: board)
    end
    self.evidences.map{|evidence| evidence.board.project}.pluck(:id).uniq.each do |project_id|
     create_notification(recipient_id: project_id, actor_id: project_id , action: "evidences", notifiable: Project.find(project_id), reference: self)
    end
  end
end
