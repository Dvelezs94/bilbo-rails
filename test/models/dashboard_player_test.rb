require 'test_helper'

class DashboardPlayerTest < ActiveSupport::TestCase
  setup do
    @name = "Dashboard Player"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @dashboard_player = create(:dashboard_player, project: @user.projects.first) 
  end
  test "create player" do
    assert_equal true, @project.dashboard_player.present?
   end
end
