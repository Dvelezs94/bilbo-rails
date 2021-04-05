class Content < ApplicationRecord
  include ContentUploader::attachment(:multimedia)
  belongs_to :project
  has_many :contents_board_campaign, class_name: "ContentsBoardCampaign", dependent: :delete_all

  def is_image?
    begin
      multimedia.content_type.include? "image"
    rescue
      false
    end
  end

  def is_video?
    begin
      multimedia.content_type.include? "video"
    rescue
      false
    end
  end

  def get_format
    if multimedia_data.present?
      return "image" if is_image?
      return "video" if is_video?
    else
      return "html" if url.present?
    end
  end
end
