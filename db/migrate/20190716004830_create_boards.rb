class CreateBoards < ActiveRecord::Migration[5.2]
  def change
    create_table :boards do |t|
      t.references :user, foreign_key: true
      t.float :lat
      t.float :lng
      t.integer :avg_daily_views
      t.float :width
      t.float :height
      t.integer :duration
      t.integer :status
      t.string :description
      # north face, south, etc
      t.integer :face

      t.timestamps
    end
  end
end
