class CreateEvidences < ActiveRecord::Migration[6.0]
  def change
    create_table :evidences do |t|
      t.string :multimedia_data
      t.references :board, null: false, foreign_key: true
      t.references :witness, null: false, foreign_key: true

      t.timestamps
    end
  end
end
