class RemoveAssetBalanceFromPortfolios1 < ActiveRecord::Migration[8.0]
  def change
    remove_column :portfolios, :balance_asset, :decimal
  end
end
