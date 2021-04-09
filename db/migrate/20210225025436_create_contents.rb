class CreateContents < ActiveRecord::Migration[6.0]
  def change
    create_table :contents do |t|
      t.string :slug
      t.string :url
      t.string :multimedia_data
      t.references :project, foreign_key: true

      t.timestamps
    end
    add_index :contents, :slug, unique: true
  end
end
