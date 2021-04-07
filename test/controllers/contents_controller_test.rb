require 'test_helper'
include ContentUploader::Attachment.new(:multimedia)

class ContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user,name: "Provider" , email: "#{name}@bilbo.mx".downcase, roles: "provider")
    sign_in @user
    @project = @user.projects.first
    @content = create(:content, project: @project)
  end

  test "Redirected if not logged in" do
    sign_out :user
    get contents_url
    assert_response :redirect
  end
end
