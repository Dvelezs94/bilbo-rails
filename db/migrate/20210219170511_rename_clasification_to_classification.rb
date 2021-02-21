class RenameClasificationToClassification < ActiveRecord::Migration[6.0]
  def change
    rename_column :campaigns, :clasification, :classification
  end
end
