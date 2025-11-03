class AddDefaultToPortolioValues < ActiveRecord::Migration[8.0]
  def change
    change_column_default :portfolios, :balance_fiat, from: nil, to: 0
    change_column_default :portfolios, :balance_asset, from: nil, to: 0
  end
end
