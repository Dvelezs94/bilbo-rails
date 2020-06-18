class AddSocialClassToBoards < ActiveRecord::Migration[5.2]
  def change
    add_column :boards, :social_class, :integer, default: 0
  end
end
