class AddPriceToImpressions < ActiveRecord::Migration[5.2]
  def change
    add_column :impressions, :total_price, :float
  end
end
