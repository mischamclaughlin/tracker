class AddForeignKeyToPrices < ActiveRecord::Migration[8.0]
  def change
    add_index :prices, :coin_id
    
    add_foreign_key :prices, :coins, column: :coin_id
  end
end
