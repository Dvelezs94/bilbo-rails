require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  setup do
    @project_name = "Number Seventeen"
    @project = create(:project, name: @project_name)
  end

  test "has name" do
    assert_equal @project_name, @project.name
  end

  test "can disable project" do
    assert @project.disabled!
    assert_equal "disabled", @project.status
  end

  test "can enable project" do
    assert @project.enabled!
    assert_equal "enabled", @project.status
  end
end
