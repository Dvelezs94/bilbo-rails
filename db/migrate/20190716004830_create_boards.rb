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
      t.integer :status, default: 0
      t.string :address
      t.string :images
      t.string :name
      t.string :category
      # expected earnings for 70% of use in USD
      t.integer :base_earnings
      # north face, south, etc
      t.string :face
      t.string :access_token

      t.timestamps
    end
  end
end
