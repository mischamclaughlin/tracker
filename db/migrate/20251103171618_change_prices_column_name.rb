class ChangePricesColumnName < ActiveRecord::Migration[8.0]
  def change
    rename_column :prices, :asset, :asset_id
  end
end
