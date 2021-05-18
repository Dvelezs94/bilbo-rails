require 'test_helper'
require 'shrine_helper'

class ContentsBoardCampaignsControllerTest < ActionDispatch::IntegrationTest
  i_suck_and_my_tests_are_order_dependent!
  setup do
    @name = "Content Board Campaign Test #{Faker::Name.name}"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: 50000, provider_earnings: 40000, face: "north")
    @campaign = create(:campaign, name: "raw", project: @user.projects.first, project_id: @project.id, boards: [@board], provider_campaign: @user.is_provider?, state: true, budget_distribution: {"#{@board.id}": "50.0"}.to_json)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1, budget: 50.0)
  end

  test "can get contents for wizard modal url" do
    sign_in @user
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    get get_contents_wizard_modal_contents_board_campaign_index_url, params: { board_slug: "slug-"+@board.slug, board_name: @board.name, campaign: @campaign.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get contents for wizard modal image png" do
    sign_in @user
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    post create_multimedia_contents_url, params: { multimedia: @image_attachment }, xhr: true
    get get_contents_wizard_modal_contents_board_campaign_index_url, params: { board_slug: "slug-"+@board.slug, board_name: @board.name, campaign: @campaign.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get contents for wizard modal image jpg" do
    sign_in @user
    @image_attachment = fixture_file_upload('test_image.jpg','image/jpg')
    post create_multimedia_contents_url, params: { multimedia: @image_attachment }, xhr: true
    get get_contents_wizard_modal_contents_board_campaign_index_url, params: { board_slug: "slug-"+@board.slug, board_name: @board.name, campaign: @campaign.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get contents for wizard modal video" do
    sign_in @user
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    post create_multimedia_contents_url, params: { multimedia: @video_attachment }, xhr: true
    get get_contents_wizard_modal_contents_board_campaign_index_url, params: { board_slug: "slug-"+@board.slug, board_name: @board.name, campaign: @campaign.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get selected contents for wizard modal url" do
    sign_in @user
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    get get_selected_content_contents_board_campaign_index_url, params: {selected_contents: @content.to_s, board_slug: "slug-"+@board.slug, campaign: @campaign.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get selected contents for wizard modal image" do
    sign_in @user
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    get get_selected_content_contents_board_campaign_index_url, params: {selected_contents: @content.to_s, board_slug: "slug-"+@board.slug, campaign: @campaign.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get selected contents for wizard modal video" do
    sign_in @user
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    post create_multimedia_contents_url, params: { multimedia: @video_attachment }, xhr: true
    get get_selected_content_contents_board_campaign_index_url, params: {selected_contents: @content.to_s, board_slug: "slug-"+@board.slug, campaign: @campaign.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "cant delete content image" do
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    @boards_campaigns.contents_board_campaign.create(content_id: @content.id)
    delete content_path(@content.id)
    assert_equal 1, @project.contents.size
  end

  test "cant delete content url" do
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    @boards_campaigns.contents_board_campaign.create(content_id: @content.id)
    delete content_path(@content.id)
    assert_equal 1, @project.contents.size
  end

  test "can delete content" do
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    ContentsBoardCampaign.last.delete
    assert true, @content_board_campaign.present?
  end

end
