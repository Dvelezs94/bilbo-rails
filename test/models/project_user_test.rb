require 'test_helper'

class ProjectUserTest < ActiveSupport::TestCase
  setup do
    @name = "Subscriber"
    @email = "#{@name}@bilbo.mx".downcase
    @user = create(:user, name: @name)
    @project = create(:project, name: @name, status: "enabled")
    @project_user = create(:project_user, email: @email, project: @project, user: @user)
  end
  test "has email" do
    assert_equal @email, @project_user.email
  end

  test "has project" do
    assert_equal @name, @project_user.project.name
  end
end
