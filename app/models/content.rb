class Content < ApplicationRecord
  include ContentUploader::attachment(:multimedia)
  belongs_to :project
  has_many :contents_board_campaign, class_name: "ContentsBoardCampaign", dependent: :delete_all
  validate :multimedia_or_url

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

  def is_url?
    begin
      get_format.include? "html"
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

  private
  def multimedia_or_url
    if url.present?
      errors.add(:url, "cannot assign because multimedia is set") if multimedia.present?
    elsif multimedia.present?
      errors.add(:multimedia, "cannot assign because url is set") if url.present?
    else
      errors.add(:multimedia, "Field cannot be empty if url is not set")
    end
  end
end
