class AddSlugToEvidences < ActiveRecord::Migration[6.0]
  def change
    add_column :evidences, :slug, :string
    add_index :evidences, :slug, unique: true
  end
end
