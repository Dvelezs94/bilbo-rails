require 'test_helper'
require 'shrine_helper'

class BoardCampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Board Campaign Test with contents"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "raw", project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    sign_in @user
  end
  test "board campaign when create video content board campaign" do
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    post contents_url, params: { content: { multimedia: @video_attachment } }
    @content = @user.projects.first.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal @boards_campaigns.id, @content_board_campaign.boards_campaigns_id
  end

  test "board campaign when create image png content board campaign" do
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    post contents_url, params: { content: { multimedia: @image_attachment } }
    @content = @project.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @content_board_campaign.present?
    assert_equal true, @content.is_image?
    assert_equal true, @boards_campaigns.contents_board_campaign.present?
  end

  test "board campaign when create image jpg content board campaign" do
    @image_attachment = fixture_file_upload('test_image.jpg','image/jpg')
    post contents_url, params: { content: { multimedia: @image_attachment } }
    @content = @project.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @content_board_campaign.present?
    assert_equal true, @content.is_image?
    assert_equal true, @boards_campaigns.contents_board_campaign.present?
  end

  test "board campaign when create url content board campaign" do
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @content_board_campaign.present?
    assert_equal true, @content.is_url?
    assert_equal true, @boards_campaigns.contents_board_campaign.present?
  end

end
