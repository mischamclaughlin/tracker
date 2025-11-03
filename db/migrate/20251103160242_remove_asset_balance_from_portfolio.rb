class RemoveAssetBalanceFromPortfolio < ActiveRecord::Migration[8.0]
  def change
    remove_column :portfolios, :asset_balance, :decimal
  end
end
