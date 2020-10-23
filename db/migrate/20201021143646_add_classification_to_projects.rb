class AddClassificationToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :classification, :int, default: 0
  end
end
