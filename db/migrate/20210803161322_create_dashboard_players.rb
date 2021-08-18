class CreateDashboardPlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :dashboard_players do |t|
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
