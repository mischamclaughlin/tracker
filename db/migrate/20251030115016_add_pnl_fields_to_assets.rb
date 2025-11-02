class AddPnlFieldsToAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :assets, :total_bought, :decimal, precision: 30, scale: 18, default: 0
    add_column :assets, :total_spent, :decimal, precision: 30, scale: 2, default: 0
    add_column :assets, :avg_buy_price, :decimal, precision: 30, scale: 2, default: 0
    add_column :assets, :total_sold, :decimal, precision: 30, scale: 18, default: 0
    add_column :assets, :total_received, :decimal, precision: 30, scale: 2, default: 0
    add_column :assets, :realised_pnl, :decimal, precision: 30, scale: 2, default: 0
  end
end
