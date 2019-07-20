class CreatePrints < ActiveRecord::Migration[5.2]
  def change
    create_table :prints do |t|
      t.references :bilbo, foreign_key: true
      t.float :price, default: 0.0
      t.timestamps
    end
  end
end
