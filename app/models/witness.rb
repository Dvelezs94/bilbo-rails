class Witness < ApplicationRecord
  include NotificationsHelper
  extend FriendlyId
  friendly_id :friendly_uuid, use: :slugged
  belongs_to :campaign
  has_many :evidences, dependent: :delete_all
  enum status: { pending: 0, ready: 1 }
  after_create :create_notification_evidence


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

  def has_pending_evidences?(project)
    # Checks wether all the evidences have been uploaded by a specific project
    # If true, it means the project has pending evidences
    # If false, it means the project has sent all evidences (at least 1)
    # Returns true or false

    boards = project.boards.pluck(:id)
    pending_project_evidences = self.evidences.where(board_id: boards, multimedia_data: nil)
    if pending_project_evidences.present?
      return true
    else
      return false
    end
  end
end
