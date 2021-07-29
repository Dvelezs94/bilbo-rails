require 'test_helper'
require 'shrine_helper'

class BoardDefaultContentsControllerTest < ActionDispatch::IntegrationTest
  i_suck_and_my_tests_are_order_dependent!
  setup do
    @name = "Content Board Campaign Test #{Faker::Name.name}"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @board = create(:board, project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: 50000, provider_earnings: 40000, face: "north")
  end

  test "can get contents for board default content modal url" do
    sign_in @user
    @content = create(:content, project: @project, url: "https://bilbo.mx")
    get contents_board_modal_board_default_contents_url, params: { board_slug: @board.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get contents for board default content modal image png" do
    sign_in @user
    @image_attachment = fixture_file_upload('test_image.png','image/png')
    post create_multimedia_contents_url, params: { multimedia: @image_attachment }, xhr: true
    get contents_board_modal_board_default_contents_url, params: { board_slug: @board.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get contents for board default content modal image jpg" do
    sign_in @user
    @image_attachment = fixture_file_upload('test_image.jpg','image/jpg')
    post create_multimedia_contents_url, params: { multimedia: @image_attachment }, xhr: true
    get contents_board_modal_board_default_contents_url, params: { board_slug: @board.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

  test "can get contents for board default content modal video" do
    sign_in @user
    @video_attachment = fixture_file_upload('test_video.mp4','video/mp4')
    post create_multimedia_contents_url, params: { multimedia: @video_attachment }, xhr: true
    get contents_board_modal_board_default_contents_url, params: { board_slug: @board.slug}, xhr: true
    assert_response :success
    assert_equal true, @user.projects.first.contents.first.present?
  end

end
