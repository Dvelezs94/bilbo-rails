class CreateBilbos < ActiveRecord::Migration[5.2]
  def change
    create_table :bilbos do |t|
      t.references :user, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.integer :avg_daily_views
      t.float :width
      t.float :height
      t.integer :duration
      t.integer :status
      # north face, shout, etc
      t.integer :face
      t.string :uuid

      t.timestamps
    end
  end
end
