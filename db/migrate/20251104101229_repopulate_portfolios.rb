class RepopulatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.timestamps
    end
    add_column :portfolios, :portfolio_name, :string
    add_column :portfolios, :fiat_balance, :decimal, precision: 30, scale: 2, default: 0.0
    add_column :portfolios, :description, :string
  end
end
