class AddNewColumnsToPortfolio < ActiveRecord::Migration[8.0]
  def change
    add_column :portfolios, :balance, :decimal, precision: 30, scale: 2, default: 0.0, null: false
    add_column :portfolios, :total_invested, :decimal, precision: 30, scale: 2, default: 0.0, null: false
    add_column :portfolios, :profit_loss, :decimal, precision: 30, scale: 2, default: 0.0, null: false
    add_column :portfolios, :profit_loss_percentage, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
