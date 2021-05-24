require 'test_helper'
require 'shrine_helper'

class WitnessesControllerTest < ActionDispatch::IntegrationTest
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
    post witnesses_url, params: { witness: { campaign_id: @campaign.id } }
    assert_response :redirect
    assert_equal 1, @campaign.witnesses.size
    assert_equal 1, @campaign.witnesses.first.evidences.size
    assert_equal 2, Notification.all.size
  end


  test "validate weekly generation of witness" do
    post witnesses_url, params: { witness: { campaign_id: @campaign.id } }
    assert_response :redirect
    post witnesses_url, params: { witness: { campaign_id: @campaign.id } }
    assert_response :redirect
    assert_equal 1, @campaign.witnesses.size
  end

  test "cant create two witnesses" do
    post witnesses_url, params: { witness: { campaign_id: @campaign.id } }
    assert_response :redirect
    assert_equal 1, @campaign.witnesses.size
  end

  test "can create witness if not logged" do
    sign_out @user
    post witnesses_url, params: { witness: { campaign_id: @campaign.id } }
    assert_redirected_to analytics_campaign_path(@campaign.slug)
  end

  test "show evidences modal" do
    @witness = create(:witness, campaign_id: @campaign.id)
    @evidence = create(:evidence, board_id: @board.id, witness_id: @witness.id, multimedia_data: TestData.image_data)
    assert_equal 1, @witness.evidences.size
    get evidences_witness_modal_witness_url(@witness), xhr: true
    assert_response :success
  end
end
