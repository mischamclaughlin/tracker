class ChangePrecisionForPricesPrice < ActiveRecord::Migration[8.0]
  def change
    change_column :prices, :price, :decimal, precision: 30, scale: 2
  end
end
