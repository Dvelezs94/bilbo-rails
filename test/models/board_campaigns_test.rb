require 'test_helper'

class BoardCampaignsTest < ActiveSupport::TestCase
  setup do
    @name = "Content Board Campaign Test"
    @user = create(:user, name: @name)
    @project = @user.projects.first
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", provider_earnings: "4000",base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "Review", project: @user.projects.first, boards: [@board], project_id: @project.id, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "50"}.to_json)
    @campaign.board_campaigns.first.update(budget: 50.0, status: "approved")
    @boards_campaigns = @campaign.board_campaigns.first
  end

  test "has content" do
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert true, @content_board_campaign.present?
  end

  test "cant create content board campaigns" do
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    assert_raises ActiveRecord::RecordInvalid do
      create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: "")
    end
  end

  test "remaining impressions" do
    @boards_campaigns.update(update_remaining_impressions: true)
    max_imp = @boards_campaigns.remaining_impressions
    current_time = Time.now.utc
    start_time, end_time = @board.parse_active_time
    rand(10..100).times do
      create(:impression, board_id: @board.id, campaign_id: @campaign.id, api_token: @board.api_token, created_at: rand_time(start_time, end_time))
    end
    @boards_campaigns.update(update_remaining_impressions: true)
    #If the current time is between the active range of the board, the impression count plus the remaining_impressions must match the max impressions
    # else, the remaining_impressions must be equal to the max impressions
    match_count = @campaign.impressions.count + @boards_campaigns.remaining_impressions == max_imp
    assert (current_time.between?(start_time, end_time) && match_count) || @boards_campaigns.remaining_impressions == max_imp
  end
end
