require 'test_helper'

class CampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @campaign_name = "Zoro"
    @user = create(:user, name: @campaign_name )
    @board_id = "2"
    @board = create(:board,project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720",
      address: "mineria 908", category: "A", base_earnings: "5000", face: "north", id: @board_id)
    @project =  create(:project, name: @campaign_name)
    @campaign = create(:campaign, name: @campaign_name,project: @user.projects.first, project_id: @project.id)
    sign_in @user
  end

  test "Campaign Name" do
    @campaign = create(:campaign, name: "controller",project: @user.projects.first, project_id: @project.id, state: true)
    assert @campaign.name, @campaign_name
  end
  test "campaign index" do
    get campaigns_url
    assert_response :success
  end
  test "provider index"do
    @user2 = create(:user,name: @campaign_name, email: "#{name}@bilbo.mx".downcase, roles: "provider")
    sign_in @user2
    get provider_index_campaigns_url
    assert_response :success
  end
  test "get analytics" do
    get analytics_campaign_url(@campaign.id)
    assert_response :success
  end
  test "deny access without log in" do
    sign_out :user
    get campaigns_url
    assert_response :redirect
  end
end
