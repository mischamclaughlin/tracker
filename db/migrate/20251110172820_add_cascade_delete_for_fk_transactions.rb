class AddCascadeDeleteForFkTransactions < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :transactions, :portfolios
    add_foreign_key :transactions, :portfolios, on_delete: :cascade
    remove_foreign_key :holdings, :portfolios
    add_foreign_key :holdings, :portfolios, on_delete: :cascade
  end
end
