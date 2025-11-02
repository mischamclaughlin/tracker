class AddBalanceInFiatToAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :assets, :balance_in_fiat, :decimal, precision: 30, scale: 2
    add_index :assets, :balance_in_fiat
  end
end
