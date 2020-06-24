class AddFieldsToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :category, :string
    add_reference :reports, :campaign, foreign_key: true
    add_reference :reports, :board, foreign_key: true
  end
end
