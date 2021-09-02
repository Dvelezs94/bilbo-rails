class AddRotationDegreesToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :rotation_degrees, :float, default: 0
  end
end
