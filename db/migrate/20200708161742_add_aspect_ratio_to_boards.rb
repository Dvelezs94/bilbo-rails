class AddAspectRatioToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :aspect_ratio, :string
  end
end
