class CreateBoardSales < ActiveRecord::Migration[6.0]
  def change
    create_table :board_sales do |t|
      t.references :board, null: false, foreign_key: true
      t.references :sale, null: false, foreign_key: true

      t.timestamps
    end
  end
end
