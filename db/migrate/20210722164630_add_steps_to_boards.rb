class AddStepsToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :steps, :boolean, default: false
    add_column :boards, :multiplier, :integer
  end
end
