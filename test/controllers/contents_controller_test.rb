require 'test_helper'
require 'shrine_helper'

class ContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Content Test"
    @user = create(:user, name: @name)
    @project = @user.projects.first
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
  end

  test "can access content" do
    sign_in @user
    get contents_url
    assert_response :success
  end

  test "Redirected if not logged in" do
    sign_out :user
    get contents_url
    assert_response :redirect
  end

  test "can create url content" do
    sign_in @user
    assert_difference @project.contents, 1 do
      post contents_url, params: { content: { url: "https://bilbo.mx" } }
    end
    assert_equal true, Content.last.is_url?
    assert_redirected_to contents_path
  end

  test "can create image content" do
    sign_in @user
    assert_difference @project.contents, 1 do
      post contents_url, params: { content: { multimedia: @image_attachment } }
    end
    assert_equal true, Content.last.is_image?
    assert_redirected_to contents_path
  end

  test "can create video content" do
    sign_in @user
    assert_difference @project.contents, 1 do
      post contents_url, params: { content: { multimedia: @video_attachment } }
    end
    assert_equal true, Content.last.is_video?
    assert_redirected_to contents_path
  end

  test "can delete content" do
    sign_in @user
    assert_difference @project.contents, 1 do
      post contents_url, params: { content: { multimedia: @video_attachment } }
    end
    assert_redirected_to contents_path

    assert_difference @project.contents, -1 do
      delete content_path(Content.last.id)
    end
    assert_redirected_to contents_path
  end

  test "cannot delete content if not logged in" do
    sign_in @user
    assert_difference @project.contents, 1 do
      post contents_url, params: { content: { multimedia: @video_attachment } }
    end
    assert_redirected_to contents_path

    sign_out :user
    assert_difference @project.contents, 0 do
      delete content_path(Content.last.id)
    end
    assert_redirected_to user_session_path
  end

  test "modal review content" do
    sign_in @user
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    @board = create(:board,project: @user.projects.first, name: "FLUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, name: "Review", project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    get contents_modal_review_content_url(@boards_campaigns.id), params: { content: { images_only: false }}, xhr: true
    assert_response :success
  end
end
