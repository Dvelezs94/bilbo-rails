class CreateBoardPhotos < ActiveRecord::Migration[6.0]
  def change
    create_table :board_photos do |t|
      t.references :board, foreign_key: true
      t.text       :image_data
      t.timestamps
    end
  end
end
