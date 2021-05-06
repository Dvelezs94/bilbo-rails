require 'test_helper'


class ContentsBoardCampaignTest < ActiveSupport::TestCase
  setup do
    @name = "Content Board Campaign Test"
    @user = create(:user, name: @name)
    @project = @user.projects.first
  end

  test "can create content board campaign url" do
    @content = create(:content, project: @project, url: "https://app.bilbo.mx/users/sign_in")
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "Review", project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true,  @content_board_campaign.present?
    assert_equal true, @content_board_campaign.content_id?
    assert_equal true, @content_board_campaign.boards_campaigns_id?
  end

  test "can create content board campaign image" do
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "Review", project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true,  @content_board_campaign.present?
    assert_equal true, @content_board_campaign.content_id?
    assert_equal true, @content_board_campaign.boards_campaigns_id?
  end


  test "cannot create empty content board campaign" do
    @content = create(:content, project: @project, url: "https://app.bilbo.mx/users/sign_in")
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "Review", project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    assert_raises ActiveRecord::RecordInvalid do
      @content_board_campaign = create(:contents_board_campaign, content_id: "", boards_campaigns_id: "")
    end
  end

end
