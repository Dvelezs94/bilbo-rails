require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  i_suck_and_my_tests_are_order_dependent!

  setup do
    @default_project_name = "Gohan"
    @user = create(:user, name: @default_project_name )
    @project = create(:project, name: @name)
    sign_in @user
  end

end
