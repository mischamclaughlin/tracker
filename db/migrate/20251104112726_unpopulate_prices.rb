class UnpopulatePrices < ActiveRecord::Migration[8.0]
  def change
    drop_table :prices, if_exists: true
  end
end
