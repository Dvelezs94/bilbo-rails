class AddLocationMetadataToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :country, :string
    add_column :boards, :country_state, :string
    add_column :boards, :city, :string
    add_column :boards, :postal_code, :string
    add_column :boards, :parameterized_name, :string
  end
end