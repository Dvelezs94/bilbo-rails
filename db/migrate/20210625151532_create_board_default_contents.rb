class CreateBoardDefaultContents < ActiveRecord::Migration[6.0]
  def change
    create_table :board_default_contents do |t|
      t.references :content, null: false, foreign_key: true
      t.references :board, null: false, foreign_key: true

      t.timestamps
    end
  end
end
