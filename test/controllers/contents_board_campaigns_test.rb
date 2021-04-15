require 'test_helper'
require 'shrine_helper'

class ContentsBoardCampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Content Test"
    @user = create(:user, name: @name)
    @project = @user.projects.first
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
  end

end
