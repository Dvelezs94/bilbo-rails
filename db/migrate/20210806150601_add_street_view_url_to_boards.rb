class AddStreetViewUrlToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :street_view_url, :string
  end
end
