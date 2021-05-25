class Evidence < ApplicationRecord
  belongs_to :board
  belongs_to :witness
  include NotificationsHelper
  include EvidenceUploader::Attachment(:multimedia)
  after_update :update_witness, if: :witness_complete?

  def is_video?
    begin
      self.multimedia.content_type.include? "video"
    rescue
      false
    end
  end

  def update_witness
    @witness = self.witness
    @witness.update(status: 1)
    create_notification(recipient_id: @witness.campaign.project.id, actor_id: @witness.campaign.project.id, action: "witness", notifiable: @witness.campaign.project, reference: @witness.campaign)
  end

  def witness_complete?
    if self.witness.pending?
      if self.witness.evidences.map{|evidence| evidence.multimedia_data.nil?}.include? true
        return false
      else
        return true
      end
    else
      return false
    end
  end
end
