class AddCyclePriceToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :cycle_price, :float
  end
end
