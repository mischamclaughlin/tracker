class CreatePrices < ActiveRecord::Migration[8.0]
  def change
    create_table :prices do |t|
      t.string :asset
      t.decimal :price, precision: 30, scale: 18
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
