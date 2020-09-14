class AddExtraPercentageEarningsToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :extra_percentage_earnings, :integer, default: 20
  end
end
