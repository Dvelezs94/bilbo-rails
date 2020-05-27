class AddQrToBoards < ActiveRecord::Migration[5.2]
  def change
    add_column :boards, :qr, :string
  end
end
