class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.string :name
      t.decimal :balance_fiat, precision: 30, scale: 2
      t.decimal :balance_asset, precision: 30, scale: 18

      t.timestamps
    end
  end
end
