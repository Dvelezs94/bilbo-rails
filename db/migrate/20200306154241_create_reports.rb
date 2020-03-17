class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :name
      t.references :project, foreign_key: true
      t.string :attachment

      t.timestamps
    end
  end
end
