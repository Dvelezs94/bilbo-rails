require 'test_helper'

class DashboardPlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Dashboard Player"
    @user = create(:user, name: @name, roles: "provider")
    @project = @user.projects.first
    @board = create(:board,project: @user.projects.first, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", provider_earnings: "4000", face: "north")
  end
  test "create player" do
    sign_in @user
    post dashboard_players_url, params: {dashboard_player: {project_id: @project.id, board_slug: @board.slug}}, xhr: true
    assert_equal true, @project.dashboard_player.board_dashboard_players.present?
    assert_response :success
  end

  test "delete player" do
    sign_in @user
    @board_delete = create(:board, project: @user.projects.first, name: "Boardito", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", provider_earnings: "4000", face: "north")
    post dashboard_players_url, params: {dashboard_player: {project_id: @project.id, board_slug: @board_delete.slug}}, xhr: true
    assert_equal true, @project.dashboard_player.board_dashboard_players.present?
    delete delete_player_dashboard_players_url, params: {board_id_dashboard_player: @board_delete.slug}, xhr: true
    assert_response :success
    assert_equal false, @project.dashboard_player.board_dashboard_players.find_by(board_id: @board_delete.id).present?
  end
end
