class CreateMapPhotosAndBoardMapPhotos < ActiveRecord::Migration[6.0]
  def change
    create_table :map_photos do |t|
      t.string     :slug
      t.text       :image_data
      
      t.timestamps
    end

    create_table :board_map_photos do |t|
      # t.references :content, null: false, foreign_key: true
      t.references :board, null: false, foreign_key: true
      t.references :map_photo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
