require 'test_helper'
require 'shrine_helper'

class CampaignsControllerTest < ActionDispatch::IntegrationTest
  i_suck_and_my_tests_are_order_dependent!
  setup do
    @campaign_name = "Zoro"
    @user = create(:user, name: @campaign_name )
    @board = create(:board,project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720",
      address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @project =  @user.projects.first
    @campaign = create(:campaign, name: @campaign_name,project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    sign_in @user
  end

  test "Campaign Name" do
    @campaign = create(:campaign, name: "controller",project: @user.projects.first, project_id: @project.id, state: true, provider_campaign: @user.is_provider?)
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

  test "copy budget campaign" do
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, classification: 0, provider_campaign: @user.is_provider?)
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 1", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 1")
    attributes_1 = @campaign.attributes.delete_if{|key, value| !["project_id", "budget", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_1.merge({boards: @campaign.boards.pluck(:id).sort})
    attributes_2 = campaign_2.attributes.delete_if{|key, value| !["project_id", "budget", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_2.merge({boards: campaign_2.boards.pluck(:id).sort})
    assert_equal attributes_1, attributes_2
  end

  test "copy campaign per minute" do
    @campaign = create(:campaign, name: "campaign per minute", project: @user.projects.first, classification: 1, provider_campaign: @user.is_provider?, imp: 3, minutes: 2)
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 2", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 2")
    attributes_1 = @campaign.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_1.merge({boards: @campaign.boards.pluck(:id).sort})
    attributes_2 = campaign_2.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_2.merge({boards: campaign_2.boards.pluck(:id).sort})
    assert_equal attributes_1, attributes_2
  end

  test "copy campaign per hour" do
    @campaign = create(:campaign, name: "campaign per hour", project: @user.projects.first, classification: 2, provider_campaign: @user.is_provider?)
    @campaign.impression_hours.create(start: "2000-01-01 09:00:00", end: "2000-01-01 11:00:00", imp: 200, day: "everyday")
    @campaign.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 13:00:00", imp: 200, day: "everyday")
    @campaign.impression_hours.create(start: "2000-01-01 13:00:00", end: "2000-01-01 15:00:00", imp: 200, day: "everyday")
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 3", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 3")
    #Validate parameters of the campaigns
    attributes_1 = @campaign.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_1.merge({boards: @campaign.boards.pluck(:id).sort})
    attributes_2 = campaign_2.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_2.merge({boards: campaign_2.boards.pluck(:id).sort})
    assert_equal attributes_1, attributes_2
    #Valide parameters from impression_hours
    attributes_1 = @campaign.impression_hours.pluck(:start, :end, :imp, :day).sort_by{|v| v[0]}
    attributes_2 = campaign_2.impression_hours.pluck(:start, :end, :imp, :day).sort_by{|v| v[0]}
    assert_equal attributes_1, attributes_2
  end

  test "differences in copies" do
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, classification: 0, provider_campaign: @user.is_provider?)
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 4", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 4")
    different_ids = @campaign.id != campaign_2.id
    different_names = @campaign.name != campaign_2.name
    different_descriptions = @campaign.description != campaign_2.description
    assert different_ids #Campaigns must have the same parameters, but the id can't be the same
    assert different_names
    assert different_descriptions
    assert_equal campaign_2.state, false
    assert_equal campaign_2.impression_count, 0
  end

  test "get boards and content for campaign" do
    get get_boards_content_info_campaign_url(@campaign.slug, selected_boards: @board.id), xhr: true
    assert_response :success
  end

  test "create image(png) content for campaign" do
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    post create_multimedia_contents_url, params: {  multimedia: @image_attachment }, xhr: true
    @content = @user.projects.first.contents.first
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.present?
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.last.content.is_image?
  end

  test "create image(jpg) content for campaign" do
    @image_attachment = fixture_file_upload('test_image.jpg','image/jpg')
    post create_multimedia_contents_url, params: {  multimedia: @image_attachment }, xhr: true
    @content = @user.projects.first.contents.first
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.present?
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.last.content.is_image?
  end

  test "create video content for campaign" do
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    post create_multimedia_contents_url, params: {  multimedia: @video_attachment }, xhr: true
    @content = @user.projects.first.contents.first
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.present?
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.last.content.is_video?
  end

  test "create url content for campaign" do
    post create_url_contents_url, params: { content: { url: "https://bilbo.mx" } }
    @content = @user.projects.first.contents.first
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.present?
    assert_equal true, @campaign.board_campaigns.last.contents_board_campaign.last.content.is_url?
  end

  test "copy campaign with contents" do
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, classification: 0, provider_campaign: @user.is_provider?)
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    post create_multimedia_contents_url, params: {  multimedia: @video_attachment }, xhr: true
    @content = @user.projects.first.contents.first
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign", description: "XXXXXXX")
    attributes_1 = @campaign.attributes.delete_if{|key, value| !["project_id", "budget", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_1.merge({boards: @campaign.boards.pluck(:id).sort})
    attributes_2 = campaign_2.attributes.delete_if{|key, value| !["project_id", "budget", "starts_at", "ends_at", "ad_id", "provider_campaign", "classification", "objective"].include?(key)}
    attributes_2.merge({boards: campaign_2.boards.pluck(:id).sort})
    assert_equal attributes_1, attributes_2
    assert_equal @campaign.board_campaigns.last.contents_board_campaign.last.content_id, campaign_2.board_campaigns.last.contents_board_campaign.last.content_id
  end
end
