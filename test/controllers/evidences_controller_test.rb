require 'test_helper'

class EvidencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @campaign_name = "Luigi"
    @user = create(:user, name: @campaign_name, roles: "provider" )
    @project =  @user.projects.first
    @campaign = create(:campaign, project: @project, provider_campaign: true, state: 1, name: @campaign_name)
    @board = create(:board,project: @project, name: "Luigi Mansion", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1, budget: 50.0)
    @witness = create(:witness, campaign_id: @campaign.id)
    sign_in @user
  end

  test "can update witness" do
    @evidence = create(:evidence, board_id: @board.id, witness_id: @witness.id, multimedia_data: TestData.image_data)
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    patch evidence_url(@evidence), params: {evidence: {multimedia_data: @video_attachment}}, xhr: true
    assert_response :success
  end

  test "new_evidence_modal" do
    @evidence = create(:evidence, board_id: @board.id, witness_id: @witness.id, multimedia_data: TestData.image_data)
    get new_evidence_evidence_url(@evidence), xhr: true
    assert_response :success
  end

end
