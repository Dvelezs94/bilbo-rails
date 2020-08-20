class AddImagesOnlyToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :images_only, :boolean, default: false
    add_column :boards, :min_time_per_ad, :integer, default: 10
  end
end
