class AddQrToShortener < ActiveRecord::Migration[6.0]
  def change
    add_column :shorteners, :qr, :string
  end
end
