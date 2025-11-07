class PopulateCoins < ActiveRecord::Migration[8.0]
  def change
    add_column :coins, :coin_name, :string
    add_column :coins, :symbol, :string
    add_column :coins, :coingecko_id, :string
  end
end
