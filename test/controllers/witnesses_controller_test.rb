require 'test_helper'

class WitnessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @campaign_name = "Luigi"
    @user = create(:user, name: @campaign_name )
    @project =  @user.projects.first
    @board = create(:board,project: @project, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720",
      address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: @campaign_name, project: @project, project_id: @project.id, provider_campaign: @user.is_provider?, state: 1)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1, budget: 50.0)
    sign_in @user
  end

  test "should get new" do
    get witnesses_new_url
    assert_response :success
  end

  test "should get create" do
    get witnesses_create_url
    assert_response :success
  end

  test "can create witness" do
    post witnesses_create_url(campaign_id: @campaign)
    assert_response :success
    assert_equal 1, Witness.all.size
  end

end
