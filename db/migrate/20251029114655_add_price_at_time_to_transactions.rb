class AddPriceAtTimeToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :price_at_time, :decimal, precision: 30, scale: 18
  end
end
