require 'test_helper'

class EvidenceTest < ActiveSupport::TestCase
  setup do
    @campaign_name = "Luigi"
    @user = create(:user, name: @campaign_name )
    @project =  @user.projects.first
    @board = create(:board,project: @project, name: "Luigi Mansion", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720",
    address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: @campaign_name, project: @project, project_id: @project.id, provider_campaign: @user.is_provider?, state: 1)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1, budget: 50.0)
    @witness = create(:witness, campaign_id: @campaign.id)
    sign_in @user
  end

  test "can create image evidence" do
    @evidence = create(:evidence, witness_id: @witness.id, board_id: @board.id, multimedia_data: TestData.image_data)
    assert_equal true, @evidence.multimedia_data.present?
    assert_equal true, @evidence.present?
  end

  test "can create evidence" do
    @evidence = create(:evidence, witness_id: @witness.id, board_id: @board.id, multimedia_data: TestData.image_data)
    assert_equal 1, @witness.evidences.size
  end

  test "update witness" do
    assert_equal true, @witness.evidences.last.multimedia_data.nil?
    @witness.evidences.last.update(multimedia_data: TestData.image_data)
    assert_equal false, @witness.evidences.last.multimedia_data.nil?
  end

  test "update witness when evidence complete" do
    @evidence = create(:evidence, witness_id: @witness.id, board_id: @board.id, multimedia_data: TestData.image_data)
    @witness.evidences.last.update(multimedia_data: TestData.image_data)
    assert_equal true, @evidence.witness_complete?
    @witness.evidences.last.update_witness
    assert_equal "ready", @witness.status
  end

  test "not update witness when evidence complete" do
    assert_equal false, @witness.evidences.last.witness_complete?
    assert_equal "pending", @witness.status
  end

end
