class AddSlugToWitnesses < ActiveRecord::Migration[6.0]
  def change
    add_column :witnesses, :slug, :string
    add_index :witnesses, :slug, unique: true
  end
end
