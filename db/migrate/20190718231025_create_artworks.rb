class CreateArtworks < ActiveRecord::Migration[5.2]
  def change
    create_table :artworks do |t|
      t.integer :width
      t.integer :height
      t.string :image
      t.references :ads, foreign_key: true

      t.timestamps
    end
  end
end
