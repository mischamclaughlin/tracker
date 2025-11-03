class AddPortfolioToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :portfolio, :string
  end
end
