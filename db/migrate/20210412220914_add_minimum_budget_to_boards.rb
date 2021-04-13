class AddMinimumBudgetToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :minimum_budget, :float, default: 50.0
  end
end
