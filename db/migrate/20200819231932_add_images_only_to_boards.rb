class AddImagesOnlyToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :images_only, :boolean, default: false
  end
end
