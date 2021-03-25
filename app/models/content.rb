class Content < ApplicationRecord
  include ContentUploader::attachment(:multimedia)
  belongs_to :project
  has_many :contents_board_campaign, class_name: "ContentsBoardCampaign", :dependent => :delete_all

  def is_image?
    multimedia.content_type.include? "image"
  end

  def is_video?
    multimedia.content_type.include? "video"
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
