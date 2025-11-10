class AddColumnsToCoin < ActiveRecord::Migration[8.0]
  def change
    add_column :coins, :fiat_balance, :decimal, precision: 30, scale: 2, default: 0.0, null: false
    add_column :coins, :coin_balance, :decimal, precision: 30, scale: 18, default: 0.0, null: false
    add_column :coins, :current_price, :decimal, precision: 30, scale: 18, default: 0.0, null: false
  end
end
