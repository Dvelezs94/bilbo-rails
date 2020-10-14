class AddMacAddressToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :mac_address, :string
  end
end
