class RemoveTotalFromTransactions < ActiveRecord::Migration[8.0]
  def change
    remove_column :transactions, :total, :decimal
  end
end
