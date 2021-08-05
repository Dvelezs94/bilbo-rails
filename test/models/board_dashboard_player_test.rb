require 'test_helper'

class BoardDashboardPlayerTest < ActiveSupport::TestCase
  setup do
    @name = "Dashboard Player"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @dashboard_player = create(:dashboard_player, project_id: @project.id) 
    @board = create(:board,project: @user.projects.first, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", provider_earnings: "4000", face: "north")
    @board_dashboard_player = create(:board_dashboard_player, dashboard_player_id: @dashboard_player.id, board_id: @board.id  ) 
  end
  test "create board dashboard player" do
    assert_equal true, @project.dashboard_player.board_dashboard_players.present?
   end
end
