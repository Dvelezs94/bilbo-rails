class SetProviderPriceToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :provider_earnings, :float
    add_column :impressions, :provider_price, :float
  end
end
