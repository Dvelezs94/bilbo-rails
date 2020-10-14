class ChangeNameToBoardsDefaultImage < ActiveRecord::Migration[6.0]
  def change
    rename_column :boards, :default_image, :default_images
  end
end
