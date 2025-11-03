class AddPortfolioToAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :assets, :portfolio, :string
  end
end
