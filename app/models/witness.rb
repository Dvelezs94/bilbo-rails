class Witness < ApplicationRecord
  include NotificationsHelper
  extend FriendlyId
  belongs_to :campaign
  has_many :evidences
  enum status: { pending: 0, ready: 1 }
  after_create :create_notification_evidence
  accepts_nested_attributes_for :evidences
  friendly_id :id, use: [:slugged, :finders]

  def create_notification_evidence
    self.campaign.board_campaigns.each do |bc|
      board = bc.board_id
      p board
      self.evidences.create(board_id: board)
    end
    self.evidences.map{|evidence| evidence.board.project}.pluck(:id).uniq.each do |project_id|
     create_notification(recipient_id: project_id, actor_id: project_id , action: "evidences", notifiable: Project.find(project_id), reference: self)
    end

    def slug_candidates
      [
        ["witness", SecureRandom.hex(10), :id]
      ]
    end
  end
end
