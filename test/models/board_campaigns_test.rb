require 'test_helper'


class BoardCampaignsTest < ActiveSupport::TestCase
  setup do
    @name = "Content Board Campaign Test"
    @user = create(:user, name: @name)
    @project = @user.projects.first
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "Review", project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
  end

  test "has content" do
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert true, @content_board_campaign.present?
  end
end
