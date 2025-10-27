class AddAmountAndTotalToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :amount, :decimal, precision: 30, scale: 18
    add_column :transactions, :total, :decimal, precision: 30, scale: 18
  end
end
