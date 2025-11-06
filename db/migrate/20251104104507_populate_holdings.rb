class PopulateHoldings < ActiveRecord::Migration[8.0]
  def change
    create_table :holdings do |t|
      t.timestamps
    end
    add_column :holdings, :coin_id, :bigint
    add_column :holdings, :portfolio_id, :bigint
    add_column :holdings, :fiat_balance, :decimal, precision: 30, scale: 2, default: 0.0
    add_column :holdings, :coin_balance, :decimal, precision: 30, scale: 18, default: 0.0

    add_index :holdings, :coin_id
    add_index :holdings, :portfolio_id

    add_foreign_key :holdings, :coins, column: :coin_id
    add_foreign_key :holdings, :portfolios, column: :portfolio_id
  end
end
