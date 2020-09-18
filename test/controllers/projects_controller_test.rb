require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  i_suck_and_my_tests_are_order_dependent!

  setup do
    @default_project_name = "Gohan"
    @user = create(:user, name: @default_project_name )
    sign_in @user
  end

  test "Project Name" do
    assert @user.projects.first.name, @default_project_name
  end


  test "can get index" do
    get projects_url
    assert_response :success
  end

  test "user has 2 projects" do
    @new_project_name = "videl"

    assert_difference 'Project.count', 1 do
      post projects_url, params: { project: { name: @new_project_name } }
    end

    assert_equal ["Gohan", @new_project_name], @user.projects.pluck(:name)
  end

  test "can remove project" do
    assert 2, @user.projects.count
    delete project_url(@user.projects.last)

    assert 1, @user.projects.count
  end

  test "cannot remove last project" do
    sign_out :user
    @user2 = create(:user, name: "Trunks" )
    sign_in @user2
    delete project_url(@user2.projects.first)
    assert 1, @user.projects.count
  end

  test "deny access without log in" do
    sign_out :user
    get projects_url
    assert_response :redirect
  end
end
