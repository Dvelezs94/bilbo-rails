class CreateBoardDashboardPlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :board_dashboard_players do |t|
      t.references :board, null: false, foreign_key: true
      t.references :dashboard_player, null: false, foreign_key: true
    end
  end
end
