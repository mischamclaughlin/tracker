class AddFiatToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :fiat, :decimal, precision: 30, scale: 2
  end
end
