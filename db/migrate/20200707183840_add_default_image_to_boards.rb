class AddDefaultImageToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :default_image, :string
  end
end
