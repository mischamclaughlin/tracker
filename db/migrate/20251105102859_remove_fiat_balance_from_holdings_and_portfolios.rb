class RemoveFiatBalanceFromHoldingsAndPortfolios < ActiveRecord::Migration[8.0]
  def change
    remove_column :holdings, :fiat_balance
    remove_column :portfolios, :fiat_balance
  end
end
