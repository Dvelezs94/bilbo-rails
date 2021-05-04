require 'test_helper'
require 'shrine_helper'

class BoardCampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Board Campaign Test with contents"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "raw", project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    sign_in @user
  end

  test "change status board campaign when create url content board campaign" do
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    @boards_campaigns.contents_board_campaign.create(content_id: @content.id)
    assert_equal "in_review",  @boards_campaigns.status
  end

  test "change status board campaign when create video content board campaign" do
    post contents_url, params: { content: { multimedia: @video_attachment } }
    @content = @user.projects.first.contents.first
    @boards_campaigns.contents_board_campaign.create(content_id: @content.id)
    assert_equal "in_review",  @boards_campaigns.status
  end

  test "change status board campaign when create image content board campaign" do
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    @boards_campaigns.contents_board_campaign.create(content_id: @content.id)
    assert_equal "in_review",  @boards_campaigns.status
  end

end
