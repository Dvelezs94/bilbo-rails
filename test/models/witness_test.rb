require 'test_helper'

class WitnessTest < ActiveSupport::TestCase
  setup do
    @campaign_name = "Luigi"
    @user = create(:user, name: @campaign_name  )
    @project =  @user.projects.first
    @board = create(:board,project: @project, name: "Luigi Mansion", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720",
      address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: @campaign_name, project: @project, project_id: @project.id, provider_campaign: @user.is_provider?, state: 1)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1, budget: 50.0)
    sign_in @user
  end

  test "can create witness" do
    @witness = create(:witness, campaign_id: @campaign.id)
    assert_equal 1, @campaign.witnesses.size
  end
end
