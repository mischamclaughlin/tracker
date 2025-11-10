class ChangeCoinColumnNameFromCurrentPriceToLatestPrice < ActiveRecord::Migration[8.0]
  def change
    rename_column :coins, :current_price, :latest_price
  end
end
