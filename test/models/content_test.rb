require 'test_helper'
require 'shrine_helper'

class ContentTest < ActiveSupport::TestCase
  setup do
    @name = "Content Test"
    @user = create(:user, name: @name)
    @project = @user.projects.first
  end

  test "can create URL content" do
    @content = create(:content, project: @project)
    assert @content.is_url?
    assert_equal true, @user.projects.first.contents.present?
  end

  test "cannot create empty content" do
    assert_raises ActiveRecord::RecordInvalid do
      create(:content, project: @project, url: "", multimedia: "")
    end
  end

  test "can create image content" do
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    assert @content.is_image?
    assert_equal true, @user.projects.first.contents.present?
  end
end
