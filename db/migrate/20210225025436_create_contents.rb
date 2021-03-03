class CreateContents < ActiveRecord::Migration[6.0]
  def change
    create_table :contents do |t|
      t.string :slug
      t.string :url
<<<<<<< HEAD
      t.string :multimedia_data
      t.integer :duration, default: 10
=======
      t.string :multimedia
>>>>>>> ad redesign first commit
      t.references :project, foreign_key: true

      t.timestamps
    end
    add_index :contents, :slug, unique: true
  end
end
