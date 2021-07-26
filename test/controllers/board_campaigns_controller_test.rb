require 'test_helper'
require 'shrine_helper'

class BoardCampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Board Campaign Test with contents"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: 50000, provider_earnings: 40000, face: "north")
    @campaign = create(:campaign, name: "raw", project: @user.projects.first, project_id: @project.id, boards: [@board], provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "50.0"}.to_json)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1, budget: 50.0)
    sign_in @user
  end
  test "create video for board campaign" do
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    post create_multimedia_contents_url, params: {  multimedia: @video_attachment }, xhr: true
    @content = @user.projects.first.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal @boards_campaigns.id, @content_board_campaign.boards_campaigns_id
  end

  test "create image png for board campaign" do
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    post create_multimedia_contents_url, params: {  multimedia: @image_attachment }, xhr: true
    @content = @project.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @content_board_campaign.present?
    assert_equal true, @content.is_image?
    assert_equal true, @boards_campaigns.contents_board_campaign.present?
  end

  test "create image jpg for board campaign" do
    @image_attachment = fixture_file_upload('test_image.jpg','image/jpg')
    post create_multimedia_contents_url, params: {  multimedia: @image_attachment }, xhr: true
    @content = @project.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @content_board_campaign.present?
    assert_equal true, @content.is_image?
    assert_equal true, @boards_campaigns.contents_board_campaign.present?
  end

  test "create url for board campaign" do
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @content_board_campaign.present?
    assert_equal true, @content.is_url?
    assert_equal true, @boards_campaigns.contents_board_campaign.present?
  end

  test "can delete content for board campaign" do
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    post create_multimedia_contents_url, params: {  multimedia: @image_attachment }, xhr: true
    @content = @project.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    @boards_campaigns.contents_board_campaign.last.delete
    assert_equal 0, @boards_campaigns.contents_board_campaign.size
  end

  test "cant delete content for board campaign" do
    @campaign_2 = create(:campaign, name: "rar", project_id: @project.id, boards: [@board], provider_campaign: @user.is_provider?, state: true, budget_distribution: {"#{@board.id}": "50.0"}.to_json)
    @board_campaign_delete = create(:boards_campaigns, campaign_id: @campaign_2.id , board_id: @board.id, status: 1, budget: 50.0)
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    post create_multimedia_contents_url, params: {  multimedia: @image_attachment }, xhr: true
    @content = @project.contents.first
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @board_campaign_delete.id)
    delete content_path(@content.id)
    assert_equal 1, @project.contents.size
  end
end
