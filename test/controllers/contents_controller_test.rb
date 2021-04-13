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
  end

  test "can create image content" do
    sign_in @user
    assert_difference @project.contents, 1 do
      post contents_url, params: { content: { multimedia: @image_attachment } }
    end
    assert Content.last.is_image?
    assert_redirected_to contents_path
  end

  test "can create video content" do
    sign_in @user
    assert_difference @project.contents, 1 do
      post contents_url, params: { content: { multimedia: @video_attachment } }
    end
    assert Content.last.is_video?
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
end
